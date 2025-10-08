# Kubernetes CP2 - Produção

Este projeto demonstra a implementação de uma aplicação web utilizando Kubernetes com práticas de produção.

## 📝 Sobre o Projeto

### Contexto Empresarial

Este projeto faz parte de uma iniciativa da **TechFleet**, empresa que está realizando a migração de suas aplicações monolíticas para uma arquitetura baseada em microserviços utilizando containers orquestrados pelo Kubernetes. A migração visa melhorar a escalabilidade, resiliência e eficiência operacional dos sistemas.

### Aluno

- **Nome:** Bruno Pinheiro dos Santos
- **RM:** 556184
- **Curso:** FIAP - Cloud Developer Kubernetes & Serverless

## 📋 Arquitetura da Solução

A aplicação segue uma arquitetura de microserviços implementada em Kubernetes, com:

- **Frontend**: Interface de usuário em container separado
- **Backend API**: Serviços RESTful containerizados
- **Banco de Dados**: Persistência gerenciada pelo Kubernetes
- **Ingress Controller**: Gerenciamento de tráfego externo
- **ConfigMaps e Secrets**: Gerenciamento de configurações e dados sensíveis

### Estratégias de Deploy

- Uso de Probes (Readiness/Liveness) para garantir alta disponibilidade
- Estratégia de Rolling Update para atualizações sem downtime
- Limites de recursos definidos para garantir estabilidade
- Monitoramento integrado para observabilidade

## 📋 Pré-requisitos

### Ferramentas Necessárias

- **Docker**: Para containerização
- **Kubernetes**: Orquestração de containers
- **kubectl**: CLI do Kubernetes
- **Git**: Controle de versão

### Instalação por Sistema Operacional

#### 🍎 macOS

**1. Instalar Homebrew (se não tiver):**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Instalar Docker Desktop:**

```bash
brew install --cask docker
```

Ou baixe do [site oficial](https://www.docker.com/products/docker-desktop/)

**3. Instalar kubectl:**

```bash
brew install kubectl
```

**4. Habilitar Kubernetes no Docker Desktop:**

- Abra o Docker Desktop
- Vá em Settings → Kubernetes
- Marque "Enable Kubernetes"
- Clique em "Apply & Restart"

#### 🐧 Linux (Ubuntu/Debian)

**1. Instalar Docker:**

```bash
# Atualizar pacotes
sudo apt update

# Instalar dependências
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Adicionar chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicionar repositório
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

**2. Instalar kubectl:**

```bash
# Baixar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Tornar executável
chmod +x kubectl

# Mover para PATH
sudo mv kubectl /usr/local/bin/
```

**3. Instalar Minikube (para ambiente local):**

```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

#### 🪟 Windows

**1. Instalar Docker Desktop:**

- Baixe do [site oficial](https://www.docker.com/products/docker-desktop/)
- Execute o instalador
- Reinicie o computador quando solicitado

**2. Instalar kubectl via Chocolatey:**

```powershell
# Instalar Chocolatey (se não tiver)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar kubectl
choco install kubernetes-cli
```

**Alternativa via download direto:**

```powershell
# Baixar kubectl
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"

# Adicionar ao PATH (mover para uma pasta no PATH ou adicionar pasta atual ao PATH)
```

**3. Habilitar Kubernetes no Docker Desktop:**

- Abra o Docker Desktop
- Vá em Settings → Kubernetes
- Marque "Enable Kubernetes"
- Clique em "Apply & Restart"

## 🚀 Executando Localmente

### 1. Clonar o Repositório

```bash
git clone <url-do-repositorio>
cd k8s-cp2-prod-kubernetes
```

### 2. Verificar Instalações

```bash
# Verificar Docker
docker --version

# Verificar kubectl
kubectl version --client

# Verificar cluster Kubernetes
kubectl cluster-info
```

### 3. Configurar Ambiente Local

#### Para macOS e Windows (Docker Desktop):

```bash
# Verificar se o contexto está correto
kubectl config current-context

# Deve mostrar 'docker-desktop'
```

#### Para Linux (Minikube):

```bash
# Iniciar Minikube
minikube start

# Verificar status
minikube status

# Configurar kubectl para usar Minikube
kubectl config use-context minikube
```

### 4. Aplicar Manifestos Kubernetes

**Criar namespace (se necessário):**

```bash
kubectl create namespace cp2-prod
```

**Aplicar todos os manifestos:**

```bash
# Aplicar ConfigMaps e Secrets primeiro
kubectl apply -f k8s/configmaps/
kubectl apply -f k8s/secrets/

# Aplicar Services
kubectl apply -f k8s/services/

# Aplicar Deployments
kubectl apply -f k8s/deployments/

# Aplicar Ingress (se houver)
kubectl apply -f k8s/ingress/
```

**Ou aplicar tudo de uma vez:**

```bash
kubectl apply -f k8s/ --recursive
```

### 5. Verificar Deployment

**Verificar pods:**

```bash
kubectl get pods -n cp2-prod
```

**Verificar services:**

```bash
kubectl get services -n cp2-prod
```

**Verificar logs:**

```bash
kubectl logs -f deployment/<nome-do-deployment> -n cp2-prod
```

### 6. Acessar a Aplicação

#### Para macOS e Windows (Docker Desktop):

```bash
# Port forward para acessar localmente
kubectl port-forward service/<nome-do-service> 8080:80 -n cp2-prod
```

#### Para Linux (Minikube):

```bash
# Obter URL do serviço
minikube service <nome-do-service> -n cp2-prod --url

# Ou usar port forward
kubectl port-forward service/<nome-do-service> 8080:80 -n cp2-prod
```

Acesse a aplicação em: `http://localhost:8080`

## 🛠️ Comandos Úteis para Desenvolvimento

### Monitoramento

```bash
# Monitorar recursos
kubectl top nodes
kubectl top pods -n cp2-prod

# Dashboard do Kubernetes (se disponível)
kubectl proxy
# Acesse: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### Debug

```bash
# Descrever recursos
kubectl describe pod <pod-name> -n cp2-prod
kubectl describe service <service-name> -n cp2-prod

# Executar comandos dentro do pod
kubectl exec -it <pod-name> -n cp2-prod -- /bin/bash

# Ver eventos
kubectl get events -n cp2-prod --sort-by='.lastTimestamp'
```

### Limpeza

```bash
# Remover todos os recursos
kubectl delete -f k8s/ --recursive

# Remover namespace
kubectl delete namespace cp2-prod
```

#### Para Linux (parar Minikube):

```bash
minikube stop
minikube delete  # Para remover completamente
```

## 📁 Estrutura do Projeto

```
k8s-cp2-prod-kubernetes/
├── k8s/
│   ├── configmaps/     # Configurações da aplicação
│   │   └── app-config.yaml
│   ├── secrets/        # Dados sensíveis
│   │   └── db-secrets.yaml
│   ├── deployments/    # Definições de deployment
│   │   ├── frontend-deployment.yaml
│   │   ├── api-deployment.yaml
│   │   └── db-statefulset.yaml
│   ├── services/       # Exposição de serviços
│   │   ├── frontend-service.yaml
│   │   ├── api-service.yaml
│   │   └── db-service.yaml
│   └── ingress/        # Regras de ingress
│       └── main-ingress.yaml
├── manifests/         # Manifestos combinados
├── scripts/           # Scripts de automação
│   ├── deploy.sh
│   └── cleanup.sh
└── README.md           # Este arquivo
```

## 🔄 CI/CD Pipeline

A TechFleet implementou um pipeline de CI/CD para automação do ciclo de vida da aplicação:

1. **Build**: Compilação e teste dos componentes
2. **Container Build**: Construção das imagens Docker
3. **Security Scanning**: Análise de segurança das imagens
4. **Artifact Storage**: Armazenamento no Registry
5. **Deployment**: Deploy automatizado em ambientes Kubernetes
6. **Monitoring**: Monitoramento contínuo pós-deploy

## 📊 Monitoramento e Observabilidade

A solução inclui:

- **Prometheus**: Coleta de métricas
- **Grafana**: Visualização de métricas
- **Loki**: Agregação de logs
- **Alertmanager**: Alertas baseados em métricas

### Dashboards recomendados:

- Status geral do cluster
- Performance dos microserviços
- Métricas de negócio
- Logs consolidados

## 🧪 Testes de Carga e Escalabilidade

Para testar a escalabilidade da solução:

```bash
# Instalar o hey (ferramenta de teste de carga)
go get -u github.com/rakyll/hey

# Executar teste de carga
hey -n 10000 -c 100 http://<ingress-url>/api/health

# Observar a escalabilidade automática
kubectl get hpa -n cp2-prod -w
```

## 🔐 Segurança

A implementação segue as melhores práticas de segurança para Kubernetes:

- NetworkPolicies para isolamento de tráfego
- RBAC para controle de acesso
- Secrets para dados sensíveis
- Imagens com least privilege
- Scanning contínuo de vulnerabilidades

## 📈 Roadmap

Próximos passos da TechFleet para evolução da plataforma:

1. Implementação de Service Mesh (Istio)
2. Integração com soluções de logging centralizado
3. Implementação de GitOps com Flux/ArgoCD
4. Expansão para multi-cloud utilizando clusters federados

## 📚 Recursos Adicionais

- [Documentação oficial do Kubernetes](https://kubernetes.io/docs/)
- [Documentação do Docker](https://docs.docker.com/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Práticas recomendadas para Kubernetes em produção](https://learnk8s.io/production-best-practices)
- [CNCF Cloud Native Landscape](https://landscape.cncf.io/)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
