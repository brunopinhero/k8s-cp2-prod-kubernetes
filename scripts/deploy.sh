#!/bin/bash

# Script de deploy para projeto TechFleet - Kubernetes Production
# Autor: Bruno Pinheiro dos Santos
# RM: 556184

# Definindo cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando deploy da aplicação TechFleet...${NC}"

# Verificando se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Erro: kubectl não está instalado!${NC}"
    exit 1
fi

# Verificando se o cluster está acessível
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Erro: Não foi possível se conectar ao cluster Kubernetes.${NC}"
    exit 1
fi

# Criando namespace se não existir
echo -e "${YELLOW}Verificando namespace...${NC}"
if ! kubectl get namespace cp2-prod &> /dev/null; then
    kubectl create namespace cp2-prod
    echo -e "${GREEN}Namespace cp2-prod criado com sucesso!${NC}"
else
    echo -e "${GREEN}Namespace cp2-prod já existe.${NC}"
fi

# Aplicando os manifestos em ordem correta
echo -e "${YELLOW}Aplicando ConfigMaps...${NC}"
kubectl apply -f ../k8s/configmaps/ -n cp2-prod

echo -e "${YELLOW}Aplicando Secrets...${NC}"
kubectl apply -f ../k8s/secrets/ -n cp2-prod

echo -e "${YELLOW}Aplicando Services...${NC}"
kubectl apply -f ../k8s/services/ -n cp2-prod

echo -e "${YELLOW}Aplicando Deployments...${NC}"
kubectl apply -f ../k8s/deployments/ -n cp2-prod

echo -e "${YELLOW}Aplicando Ingress...${NC}"
kubectl apply -f ../k8s/ingress/ -n cp2-prod

# Verificando status dos deployments
echo -e "${YELLOW}Verificando status dos deployments...${NC}"
kubectl rollout status deployment --all -n cp2-prod

# Exibindo informações dos serviços
echo -e "${YELLOW}Serviços disponíveis:${NC}"
kubectl get services -n cp2-prod

# Exibindo informações de acesso
echo -e "${GREEN}Deploy concluído com sucesso!${NC}"
echo -e "${YELLOW}Para acessar a aplicação:${NC}"
echo -e "  kubectl port-forward service/<nome-do-service> 8080:80 -n cp2-prod"
echo -e "  Acesse: http://localhost:8080"

exit 0
