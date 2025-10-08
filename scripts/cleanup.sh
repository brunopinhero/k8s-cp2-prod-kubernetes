#!/bin/bash

# Script de limpeza para projeto TechFleet - Kubernetes Production
# Autor: Bruno Pinheiro dos Santos
# RM: 556184

# Definindo cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando limpeza do ambiente...${NC}"

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

# Verificando se o namespace existe
if ! kubectl get namespace cp2-prod &> /dev/null; then
    echo -e "${YELLOW}Namespace cp2-prod não encontrado. Nada para limpar.${NC}"
    exit 0
fi

# Confirmação de segurança
read -p "Isso irá remover TODOS os recursos no namespace cp2-prod. Continuar? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo -e "${YELLOW}Operação cancelada.${NC}"
    exit 0
fi

# Removendo recursos em ordem inversa
echo -e "${YELLOW}Removendo Ingress...${NC}"
kubectl delete -f ../k8s/ingress/ -n cp2-prod --ignore-not-found=true

echo -e "${YELLOW}Removendo Deployments...${NC}"
kubectl delete -f ../k8s/deployments/ -n cp2-prod --ignore-not-found=true

echo -e "${YELLOW}Removendo Services...${NC}"
kubectl delete -f ../k8s/services/ -n cp2-prod --ignore-not-found=true

echo -e "${YELLOW}Removendo ConfigMaps...${NC}"
kubectl delete -f ../k8s/configmaps/ -n cp2-prod --ignore-not-found=true

echo -e "${YELLOW}Removendo Secrets...${NC}"
kubectl delete -f ../k8s/secrets/ -n cp2-prod --ignore-not-found=true

# Removendo namespace
echo -e "${YELLOW}Removendo namespace cp2-prod...${NC}"
kubectl delete namespace cp2-prod

echo -e "${GREEN}Limpeza concluída com sucesso!${NC}"

exit 0
