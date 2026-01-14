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

- **`charts/opengatellm`** - Core chart for deploying OpenGateLLM with Redis (Stack) and PostgreSQL (CloudNative-PG) dependencies
- **`charts/opengatellm-stack`** - Complete stack chart including OpenGateLLM core + inference (vLLM), embeddings (TEI), and search (Elasticsearch)
- `manifests` - Legacy helm chart version used for deployment on LaSuite (deprecated)

## Infrastructure provisioning
- Create a kubernetes cluster with the provider of your choice.
- We recommend having at least 3 nodes, including one with a GPU sized for the LLM you wish to use.
- Verify that the connection with your cluster is functional and that the nodes are available with `kubectl get nodes`

## Deployment 
- Customize the deployment in `opengatellm-stack/values.yaml`, for example the tag of the API version to deploy, rate limiting, API keys for the different deployed services (redis, elastic search, etc), ports, hardware configuration requested by each pod, etc.
- In `opengatellm-stack/values-secret.yaml`, replace the secrets and API keys with values of your choice.
- If you want to deploy from source, install the helm chart from the `opengatellm-stack` folder : `helm install opengatellm-stack . --namespace opengatellm --create-namespace -f values-secrets.yaml -f values.yaml`
- If you want to deploy from the published version, add the repo with `helm repo add opengatellm https://etalab-ia.github.io/opengatellm-helm/; helm repo update` and install it with `helm install opengatellm-stack opengatellm/opengatellm-stack --namespace opengatellm --create-namespace -f values-secrets.yaml -f values.yaml`
- Monitor the deployment via the kubernetes dashboard, or via a tool like `k9s`.
- If some components don't start, or are stuck in "Pending", check why with `kubectl describe <pod_name>`.
- If they start but remain in error, you can check the logs with `kubectl logs <pod_name>`
- The entire stack can take 10-15 minutes to deploy. The longest is usually the embedding model as it runs on CPU (~10 minutes).
- The "API" deployment needs to be restarted once the embedding is ready, so that it can load it.
- Once all services are "Running", you can get the public IP of the load balancer with `kubectl describe svc opengatellm`.
- Use the value of `LoadBalancer Ingress` to contact the API, for example:


To list the available models, you can use the following command:
```
curl http://YOUR_LOAD_BALANCER_INGRESS_IP/v1/models \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer changeme" \
```

To test the API, you can use the following command to send a chat completion request:
```
curl http://YOUR_LOAD_BALANCER_INGRESS_IP/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer changeme" \
  -d '{
    "model": "mistralai/Mistral-Small-3.1-24B-Instruct-2503",
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
Or a request to the embeddings :

```bash 
curl -X 'POST' 'http://YOUR_LOAD_BALANCER_INGRESS_IP.fr/v1/embeddings' \
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
