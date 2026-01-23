This repository contains the helm chart to deploy [opengatellm](https://github.com/etalab-ia/OpenGateLLM/tree/main) and its components on Kubernetes.

> ⚠️ Disclaimer  
> This Helm chart is maintained on a **best-effort basis** by the OGL team.
>  
> Our production deployment is currently **not running on Kubernetes**, as we are still in the process of migrating.
> As a result, this chart may not yet include all Kubernetes production best practices.
>  
> That said, migrating to Kubernetes is an active goal for us, and this repository will be continuously improved along the way.
> If you notice any unexpected behavior or bugs, please feel free to open an issue — we’ll do our best to respond quickly.


## Repository structure

This repository provides two Helm charts:

- **`charts/opengatellm-core`** - Core chart for deploying OpenGateLLM API and its mandatory dependencies : Redis and PostgreSQL
- **`charts/opengatellm-stack`** - Chart based on OpenGateLLM core + optional dependencies : vLLM inference, TEI embeddings, and Elasticsearch
- `manifests` - Legacy helm chart version used for deployment on LaSuite (deprecated)

## Prerequisites

### Infrastructure provisioning

- Create a kubernetes cluster with the provider of your choice
- We recommend having at least 3 nodes, including one with a GPU sized for the LLM you wish to use (if using vLLM)
- Verify the connection with your cluster: `kubectl get nodes`


### K8S Operator

Before deploying the core chart, you must install the PostgreSQL operator :

```bash
# Install CloudNative-PG operator
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm install cnpg cnpg/cloudnative-pg --namespace cnpg-system --create-namespace
```

If you deploy the stack chart, you also need the ECK operator
```bash
# Install ECK operator 
helm repo add elastic https://helm.elastic.co
helm install elastic-operator elastic/eck-operator --namespace elastic-system --create-namespace

```


## Deployment

### 1. Configure your deployment

```bash
cd charts/opengatellm-stack

# Customize values.yaml for your needs (resources, models, etc.)
# Copy and customize the secrets file
cp values-secrets.example.yaml values-secrets.yaml

```

### 2. Install the chart

**From source:**
```bash
helm dependency update

# Install
helm install opengatellm-stack . \
  --namespace opengatellm \
  --create-namespace \
  -f values-secrets.yaml \
  -f values.yaml
```

**From published chart:**
```bash
helm repo add opengatellm https://etalab-ia.github.io/opengatellm-helm/
helm repo update
helm install opengatellm-stack opengatellm/opengatellm-stack \
  --namespace opengatellm \
  --create-namespace \
  -f values-secrets.yaml \
  -f values.yaml
```

### 3. Making modifications

When modifying the charts:

```bash
# 1. Make your changes to values.yaml or templates
# 2. Update dependencies if you modified the opengatellm subchart
helm dependency update

# 3. Upgrade the release
helm upgrade opengatellm-stack . \
  --namespace opengatellm \
  -f values-secrets.yaml \
  -f values.yaml
```

### 4. Accessing services

By default, services use ClusterIP. Use port-forwarding to test locally :

```bash
# API
kubectl port-forward -n opengatellm svc/opengatellm 8000:8000

# Playground
kubectl port-forward -n opengatellm svc/opengatellm-stack-playground 8501:8501
```

### 5. Monitoring

- Use `kubectl get pods -n opengatellm` to check pod status
- If pods are stuck in Pending: `kubectl describe pod <pod-name> -n opengatellm`
- Check logs: `kubectl logs <pod-name> -n opengatellm`
- The entire stack can take 10-15 minutes to deploy (embeddings model on CPU takes ~10 minutes)

## Testing the API

Once services are running and port forward is running:

List available models:
```bash
curl http://localhost:8000/v1/models \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer changeme" \
```

Test chat completions:
```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer changeme" \
  -d '{
    "model": "albert-testbed",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "Qui es tu ?"
      }
    ]}'
```

Test embeddings:
```bash
curl -X 'POST' 'http://localhost:8000/v1/embeddings' \
  -H 'accept: application/json' \
    -H "Authorization: Bearer changeme" \
    -H 'Content-Type: application/json' \
    -d '{
        "input": [0],
        "model": "embeddings-small",
        "dimensions": 0,
        "encoding_format": "float",
        "additionalProp1": {}
    }'
```

You can also run the bootstrap script : 
```bash
chmod +x ./bootstrap_ogl.sh
./bootstrap_ogl.sh
```
