# TechFleet 
# Simulação de Ambiente de Produção Kubernetes

## TechFleet Cloud Infrastructure Project

### Migração para Containers Orquestrados em Kubernetes

**Empresa:** TechFleet  
**Engenheiro de Cloud:** Bruno Pinheiro dos Santos  
**RM:** 556184  
**FIAP 2025**

---

## Introdução ao Cenário

A **TechFleet** está migrando suas aplicações para containers orquestrados em Kubernetes. Este projeto simula um ambiente de produção em Kubernetes local para validar o comportamento da aplicação web **app-portal** antes de migrá-la para a nuvem.

Como engenheiro de Cloud da TechFleet, o desafio consiste em configurar e documentar um ambiente que garanta:

- Alta disponibilidade
- Escalabilidade
- Resiliência

O objetivo é demonstrar que a aplicação funcionará adequadamente quando orquestrada em Kubernetes, comprovando sua capacidade de escalar e se recuperar automaticamente de falhas.

## Arquitetura da Solução

A solução implementada consiste em:

- **Cluster:** Kubernetes local (Minikube, Kind ou Docker Desktop)
- **Namespace:** `producao`
- **Aplicação:** Container baseado na imagem `nginx:latest`
- **Implantação:** Deployment com 3 réplicas, escalável para 5
- **Exposição:** Service do tipo NodePort (porta externa: 30080)
- **Personalização:** Página web customizada via ConfigMap

### Componentes Kubernetes

1. **Namespace**: Isolamento lógico do ambiente de produção
2. **Deployment**: Gerenciamento dos pods com 3 réplicas
3. **Service**: Exposição da aplicação via NodePort
4. **ConfigMap**: Personalização do conteúdo da página index.html

## Comandos Utilizados

### Configuração do Ambiente

```bash
# Criar o cluster (exemplo usando minikube)
minikube start

# Alternativa com Kind
# kind create cluster --name app-portal-cluster
```

### Implantação da Aplicação

```bash
# Aplicar o namespace
kubectl apply -f kubernetes/namespace.yaml

# Aplicar o ConfigMap com o conteúdo personalizado
kubectl apply -f kubernetes/configmap.yaml

# Implantar a aplicação
kubectl apply -f kubernetes/deployment.yaml

# Expor a aplicação
kubectl apply -f kubernetes/service.yaml

# Verificar os recursos criados
kubectl get all -n producao
```

### Teste de Escalabilidade

```bash
# Escalar para 5 réplicas
kubectl apply -f kubernetes/scale.yaml

# Alternativa usando o comando kubectl scale
# kubectl scale deployment/app-portal -n producao --replicas=5

# Verificar as réplicas
kubectl get pods -n producao
```

### Teste de Resiliência

```bash
# Simular falha - deletar um pod
kubectl delete pod -n producao $(kubectl get pods -n producao -l app=app-portal -o jsonpath="{.items[0].metadata.name}")

# Verificar a recuperação automática
kubectl get pods -n producao
```

### Acesso à Aplicação

```bash
# Obter URL da aplicação (Minikube)
minikube service app-portal -n producao --url

# Para Docker Desktop e Kind, acesse:
# http://localhost:30080
```

## Demonstração de Escalabilidade e Resiliência

### Escalabilidade

A aplicação foi inicialmente configurada com 3 réplicas conforme os requisitos:

```bash
kubectl get pods -n producao
```

Em seguida, foi escalada para 5 réplicas para demonstrar a capacidade de escala horizontal:

```bash
kubectl apply -f kubernetes/scale.yaml
kubectl get pods -n producao
```

Os resultados mostram que o Kubernetes criou as réplicas adicionais e o tráfego foi distribuído entre todas elas.

### Resiliência

Para testar a resiliência, um pod foi deliberadamente removido:

```bash
kubectl delete pod -n producao [NOME-DO-POD]
```

O Kubernetes detectou automaticamente a falha e iniciou um novo pod para substituir o que foi removido, mantendo o número desejado de réplicas. Este comportamento demonstra a capacidade de auto-recuperação do sistema.

## Customização da Aplicação

A aplicação possui uma página personalizada criada via ConfigMap, com as seguintes características:

- Tema azul em harmonia com as cores do Kubernetes
- Logo do Kubernetes
- Informações sobre o ambiente
- Dados do aluno e da disciplina

A interface web mostra claramente qual pod está atendendo a requisição, facilitando a visualização do balanceamento de carga entre as réplicas.

## Considerações Finais

O ambiente de produção simulado demonstrou com sucesso que a aplicação **app-portal** está pronta para ser implantada em produção na nuvem. Todas as características requisitadas foram implementadas e testadas:

- Deployment com 3 réplicas
- Service do tipo NodePort na porta 30080
- Escalabilidade horizontal para 5 réplicas
- Recuperação automática após falha
- Personalização do conteúdo via ConfigMap

A configuração implementada segue as melhores práticas de Kubernetes, incluindo:

- Uso de namespaces para isolamento lógico
- Configuração de readiness e liveness probes
- Limites e requisições de recursos
- Separação de configuração e código (via ConfigMap)

Estas práticas garantem que a aplicação opere de forma estável, eficiente e resiliente dentro do ambiente Kubernetes.

---

## Scripts de Automação

O projeto inclui scripts automatizados para facilitar o deployment e testes:

### deploy.sh

Script principal para implantação da aplicação no cluster Kubernetes com suporte a Kustomize.

```bash
./deploy.sh
```

Funcionalidades:

- Validação de pré-requisitos
- Deploy via Kustomize (preferencial) ou manifestos individuais
- Verificação de saúde dos pods
- Logging estruturado com timestamps

### test.sh

Script interativo expandido para testar escalabilidade, resiliência e funcionalidades avançadas.

```bash
./test.sh
```

Funcionalidades:

- Teste de escalabilidade manual
- Teste de resiliência com exclusão de pods
- Geração de carga para testar HPA
- Verificação de NetworkPolicy
- Monitoramento em tempo real

## Melhorias Implementadas

Este projeto foi aprimorado seguindo as melhores práticas de produção em Kubernetes:

### Segurança

- **NetworkPolicy**: Implementação de políticas de rede para controlar o tráfego
- **Resource Limits**: Limites de CPU e memória adequados para ambiente de produção
- **Labels Padronizadas**: Uso de labels seguindo as convenções do Kubernetes

### Disponibilidade

- **PodDisruptionBudget**: Garantia de disponibilidade durante manutenções
- **Startup/Liveness/Readiness Probes**: Monitoramento completo da saúde dos pods
- **Horizontal Pod Autoscaler**: Escalabilidade automática baseada em métricas

### Operabilidade

- **Kustomize**: Gestão de configurações com Kustomize
- **Scripts Melhorados**: Deploy e testes com error handling e logging estruturado
- **Monitoramento**: Configurações para observabilidade

## Estrutura do Projeto

```
k8s-cp2-prod-kubernetes/
├── kubernetes/
│   ├── namespace.yaml          # Definição do namespace
│   ├── configmap.yaml          # Configuração da página web
│   ├── deployment.yaml         # Deployment com health checks
│   ├── service.yaml           # Service NodePort
│   ├── hpa.yaml               # Horizontal Pod Autoscaler
│   ├── network-policy.yaml    # Políticas de rede
│   ├── pdb.yaml               # Pod Disruption Budget
│   ├── scale.yaml             # Configuração para 5 réplicas (legado)
│   └── kustomization.yaml     # Configuração Kustomize
├── frontend/
│   └── index.html             # Página web local (referência)
├── screenshots/               # Evidências dos testes
├── deploy.sh                  # Script de deploy otimizado
├── test.sh                    # Script de testes expandido
└── README.md                  # Este arquivo
```
