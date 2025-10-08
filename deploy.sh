#!/bin/bash

# Script para implantar a aplicação app-portal em Kubernetes
# TechFleet - Cloud Infrastructure Team
# Engenheiro: Bruno Pinheiro dos Santos
# FIAP 2025 - Projeto de Migração para Kubernetes

set -euo pipefail

# Configurações
NAMESPACE="producao"
APP_NAME="app-portal"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/kubernetes"

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
log "TechFleet - Iniciando implantação do ambiente de produção ${APP_NAME}"
echo "====================================================="

# Verifica se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl não está instalado. Por favor, instale o kubectl antes de continuar."
    exit 1
fi

# Verifica se kustomize está disponível
if ! command -v kustomize &> /dev/null && ! kubectl kustomize --help &> /dev/null; then
    log_error "kustomize não está disponível. Por favor, instale kustomize ou use uma versão do kubectl que o suporte."
    exit 1
fi

# Verifica se o cluster está acessível
log "Verificando conexão com o cluster Kubernetes..."
if ! kubectl cluster-info > /dev/null 2>&1; then
    log_error "Não foi possível conectar ao cluster Kubernetes."
    log_error "Verifique se o cluster está em execução (minikube start ou kind create cluster)."
    exit 1
fi

log_success "Conectado ao cluster Kubernetes"

# Verifica se o diretório de manifestos existe
if [[ ! -d "${MANIFESTS_DIR}" ]]; then
    log_error "Diretório de manifestos não encontrado: ${MANIFESTS_DIR}"
    exit 1
fi

# Função para aplicar manifestos com retry
apply_manifest() {
    local manifest=$1
    local retries=3
    local count=0
    
    while [[ $count -lt $retries ]]; do
        if kubectl apply -f "${MANIFESTS_DIR}/${manifest}"; then
            log_success "Aplicado: ${manifest}"
            return 0
        else
            ((count++))
            log_error "Falha ao aplicar ${manifest}. Tentativa ${count}/${retries}"
            sleep 2
        fi
    done
    
    log_error "Falha ao aplicar ${manifest} após ${retries} tentativas"
    return 1
}

# Implanta usando Kustomize (preferencial) ou aplicação individual
if [[ -f "${MANIFESTS_DIR}/kustomization.yaml" ]]; then
    log "Implantando usando Kustomize..."
    if kubectl apply -k "${MANIFESTS_DIR}"; then
        log_success "Aplicação implantada via Kustomize"
    else
        log_error "Falha na implantação via Kustomize"
        exit 1
    fi
else
    log "Implantando manifestos individuais..."
    
    # Ordem específica para evitar dependências
    for manifest in namespace.yaml configmap.yaml deployment.yaml service.yaml hpa.yaml network-policy.yaml pdb.yaml; do
        if [[ -f "${MANIFESTS_DIR}/${manifest}" ]]; then
            log "Aplicando ${manifest}..."
            if ! apply_manifest "${manifest}"; then
                exit 1
            fi
        else
            log "Manifesto ${manifest} não encontrado, pulando..."
        fi
    done
fi

# Aguarda a criação dos pods
log "Aguardando a criação dos pods..."
if ! kubectl wait --for=condition=ready pod -l app=${APP_NAME} -n ${NAMESPACE} --timeout=120s; then
    log_error "Timeout aguardando pods ficarem prontos"
    exit 1
fi

# Verifica o status dos recursos criados
log "Verificando recursos criados:"
echo "---------------------------------------------------"
kubectl get namespace ${NAMESPACE} 2>/dev/null || log_error "Namespace ${NAMESPACE} não encontrado"
echo "---------------------------------------------------"
kubectl get all,hpa,networkpolicy,pdb -n ${NAMESPACE}

# Instruções para acesso
echo ""
echo "====================================================="
log_success "Implantação concluída com sucesso!"
echo "====================================================="
echo ""
log "Para acessar a aplicação:"

# Verifica se está usando Minikube
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    SERVICE_URL=$(minikube service ${APP_NAME} -n ${NAMESPACE} --url 2>/dev/null || echo "Erro ao obter URL do Minikube")
    echo "   URL Minikube: ${SERVICE_URL}"
else
    echo "   URL: http://localhost:30080"
fi

echo ""
log "Comandos úteis:"
echo "   Verificar status dos pods:"
echo "   kubectl get pods -n ${NAMESPACE}"
echo ""
echo "   Verificar HPA:"
echo "   kubectl get hpa -n ${NAMESPACE}"
echo ""
echo "   Verificar logs:"
echo "   kubectl logs -n ${NAMESPACE} -l app=${APP_NAME}"
echo ""
echo "   Testar escalabilidade automática (gerar carga):"
echo "   kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh"
echo ""
echo "   Verificar NetworkPolicy:"
echo "   kubectl get networkpolicy -n ${NAMESPACE}"
echo ""
echo "====================================================="