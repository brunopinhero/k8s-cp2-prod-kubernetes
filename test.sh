#!/bin/bash

# Script para testar a escalabilidade e resiliência do app-portal
# TechFleet - Cloud Infrastructure Team
# Engenheiro: Bruno Pinheiro dos Santos
# FIAP 2025 - Projeto de Migração para Kubernetes

set -euo pipefail

# Configurações
NAMESPACE="producao"
APP_NAME="app-portal"

# Função para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1"
}

echo "====================================================="
log "Teste de Escalabilidade e Resiliência - ${APP_NAME}"
echo "====================================================="

function check_deployment() {
    log "Estado atual do Deployment:"
    kubectl get deployment ${APP_NAME} -n ${NAMESPACE} -o wide
    echo ""
    log "Pods em execução:"
    kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} -o wide
    echo ""
    log "HPA (se configurado):"
    kubectl get hpa -n ${NAMESPACE} 2>/dev/null || echo "HPA não configurado"
    echo ""
}

function wait_for_pods() {
    local expected_replicas=$1
    log "Aguardando ${expected_replicas} pods ficarem prontos..."
    
    local timeout=120
    local count=0
    while [[ $count -lt $timeout ]]; do
        local ready_pods=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} --field-selector=status.phase=Running 2>/dev/null | grep -c Running || echo "0")
        if [[ $ready_pods -eq $expected_replicas ]]; then
            log_success "Todos os ${expected_replicas} pods estão prontos"
            return 0
        fi
        sleep 2
        ((count+=2))
    done
    
    log_error "Timeout aguardando pods ficarem prontos"
    return 1
}

# Verifica se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl não está instalado. Por favor, instale o kubectl antes de continuar."
    exit 1
fi

# Verifica se o deployment existe
if ! kubectl get deployment ${APP_NAME} -n ${NAMESPACE} > /dev/null 2>&1; then
    log_error "O deployment '${APP_NAME}' não existe no namespace '${NAMESPACE}'."
    log_error "Execute primeiro o script deploy.sh para criar a aplicação."
    exit 1
fi

# Estado atual antes dos testes
check_deployment

# Menu de opções
echo "Escolha uma opção de teste:"
echo "1. Testar escalabilidade manual (escalar para 5 réplicas)"
echo "2. Testar resiliência (excluir um pod)"
echo "3. Voltar para 3 réplicas"
echo "4. Gerar carga para testar HPA"
echo "5. Verificar NetworkPolicy"
echo "6. Sair"
read -p "Opção: " opcao

case $opcao in
    1)
        log "Escalando manualmente para 5 réplicas..."
        if kubectl scale deployment ${APP_NAME} -n ${NAMESPACE} --replicas=5; then
            if wait_for_pods 5; then
                check_deployment
            fi
        else
            log_error "Falha ao escalar deployment"
        fi
        ;;
    2)
        log "Testando resiliência - excluindo um pod..."
        POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
        if [[ -n "$POD_NAME" ]]; then
            log "Excluindo pod: $POD_NAME"
            kubectl delete pod -n ${NAMESPACE} "$POD_NAME"
            
            current_replicas=$(kubectl get deployment ${APP_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.replicas}')
            if wait_for_pods "$current_replicas"; then
                check_deployment
            fi
        else
            log_error "Nenhum pod encontrado para exclusão"
        fi
        ;;
    3)
        log "Voltando para 3 réplicas..."
        if kubectl scale deployment ${APP_NAME} -n ${NAMESPACE} --replicas=3; then
            if wait_for_pods 3; then
                check_deployment
            fi
        else
            log_error "Falha ao reduzir réplicas"
        fi
        ;;
    4)
        log "Gerando carga para testar HPA..."
        log "Criando pod de geração de carga..."
        
        cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: load-generator
  namespace: ${NAMESPACE}
spec:
  containers:
  - name: load-generator
    image: busybox:1.35
    command:
    - /bin/sh
    - -c
    - "while true; do wget -q -O- http://${APP_NAME}.${NAMESPACE}.svc.cluster.local/; sleep 0.01; done"
  restartPolicy: Never
EOF
        
        log "Gerador de carga iniciado. Monitore o HPA com:"
        echo "   kubectl get hpa -n ${NAMESPACE} -w"
        echo ""
        log "Para parar o gerador de carga:"
        echo "   kubectl delete pod load-generator -n ${NAMESPACE}"
        ;;
    5)
        log "Verificando NetworkPolicy..."
        kubectl describe networkpolicy -n ${NAMESPACE} || log "NetworkPolicy não configurada"
        ;;
    6)
        log "Saindo..."
        exit 0
        ;;
    *)
        log_error "Opção inválida"
        exit 1
        ;;
esac

echo "====================================================="
log_success "Teste concluído!"
echo "====================================================="