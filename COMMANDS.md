# Comandos Úteis - Kubernetes App Portal

## Deploy e Gestão

### Deploy completo da aplicação

```bash
# Usando o script automatizado
./deploy.sh

# Ou usando Kustomize diretamente
kubectl apply -k kubernetes/

# Ou aplicando manifestos individuais
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml
kubectl apply -f kubernetes/network-policy.yaml
kubectl apply -f kubernetes/pdb.yaml
```

### Verificação de recursos

```bash
# Verificar todos os recursos no namespace
kubectl get all,hpa,networkpolicy,pdb -n producao

# Verificar apenas pods
kubectl get pods -n producao -o wide

# Verificar logs
kubectl logs -n producao -l app=app-portal

# Verificar eventos
kubectl get events -n producao --sort-by='.lastTimestamp'
```

## Teste e Monitoramento

### Escalabilidade

```bash
# Escalar manualmente
kubectl scale deployment app-portal -n producao --replicas=5

# Verificar HPA
kubectl get hpa -n producao -w

# Gerar carga para testar HPA
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -n producao -- /bin/sh
# Dentro do pod: while true; do wget -q -O- http://app-portal.producao.svc.cluster.local/; sleep 0.01; done
```

### Resiliência

```bash
# Deletar um pod para testar recuperação
kubectl delete pod -n producao $(kubectl get pods -n producao -l app=app-portal -o jsonpath="{.items[0].metadata.name}")

# Monitorar recuperação
kubectl get pods -n producao -l app=app-portal -w
```

### Acesso à aplicação

```bash
# Minikube
minikube service app-portal -n producao --url

# Port-forward (alternativa)
kubectl port-forward -n producao svc/app-portal 8080:80

# Acessar via NodePort
# http://localhost:30080 (Docker Desktop/Kind)
```

## Segurança e Rede

### NetworkPolicy

```bash
# Verificar política de rede
kubectl describe networkpolicy -n producao

# Testar conectividade
kubectl run test-pod --image=busybox -n producao --rm -it -- /bin/sh
# Dentro do pod: wget -qO- app-portal.producao.svc.cluster.local
```

### PodDisruptionBudget

```bash
# Verificar PDB
kubectl get pdb -n producao

# Simular disruption
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

## Debugging e Troubleshooting

### Logs detalhados

```bash
# Logs de todos os pods
kubectl logs -n producao -l app=app-portal --tail=100

# Logs de um pod específico
kubectl logs -n producao <pod-name> -f

# Logs anteriores (se pod reiniciou)
kubectl logs -n producao <pod-name> --previous
```

### Status detalhado

```bash
# Descrever deployment
kubectl describe deployment app-portal -n producao

# Descrever pods
kubectl describe pods -n producao -l app=app-portal

# Verificar recursos utilizados
kubectl top pods -n producao
kubectl top nodes
```

### Health checks

```bash
# Verificar readiness
kubectl get pods -n producao -l app=app-portal -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}'

# Verificar probes
kubectl describe pod -n producao <pod-name> | grep -A 10 "Liveness\|Readiness\|Startup"
```

## Limpeza

### Remover aplicação

```bash
# Remover todos os recursos
kubectl delete -k kubernetes/

# Ou remover namespace completo
kubectl delete namespace producao

# Remover recursos específicos
kubectl delete deployment,service,configmap,hpa,networkpolicy,pdb -n producao -l app=app-portal
```

## Backup e Restore

### Backup de configurações

```bash
# Backup de todos os recursos
kubectl get all,hpa,networkpolicy,pdb -n producao -o yaml > backup-producao.yaml

# Backup específico
kubectl get deployment app-portal -n producao -o yaml > deployment-backup.yaml
```

### Restore

```bash
# Restore completo
kubectl apply -f backup-producao.yaml

# Restore específico
kubectl apply -f deployment-backup.yaml
```

## Validação

### Verificar se tudo está funcionando

```bash
# 1. Pods rodando
kubectl get pods -n producao -l app=app-portal

# 2. Service acessível
kubectl get svc -n producao

# 3. HPA configurado
kubectl get hpa -n producao

# 4. NetworkPolicy ativa
kubectl get networkpolicy -n producao

# 5. PDB configurado
kubectl get pdb -n producao

# 6. Teste de conectividade
curl http://localhost:30080 # ou URL do Minikube
```

## Performance

### Métricas de recursos

```bash
# CPU/Memória dos pods
kubectl top pods -n producao

# CPU/Memória dos nodes
kubectl top nodes

# Métricas do HPA
kubectl describe hpa -n producao
```

### Análise de performance

```bash
# Verificar limites e requests
kubectl describe pods -n producao -l app=app-portal | grep -A 2 "Limits\|Requests"

# Verificar utilização vs limites
kubectl top pods -n producao --containers
```
