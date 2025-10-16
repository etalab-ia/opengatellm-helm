This repository contains the helm chart to deploy [opengatellm](https://github.com/etalab-ia/OpenGateLLM/tree/main) and its components on Kubernetes.

## Repository structure

- In `opengatellm-stack` folder, there is the helm chart to deploy opengatellm and its components on Kubernetes.

## Provisioning

## Infrastructure
- Create a kubernetes cluster with the provider of your choice.
- We recommend having at least 3 nodes, including one with a GPU sized for the LLM you wish to use.
- Add the following label to your gpu node : `k8s.scaleway.com/pool-name: "gpu"`, and for your other nodes : `k8s.scaleway.com/pool-name: "cpu-ram"` so that each deployment goes to the appropriate node.
- Verify that the connection with your cluster is functional and that the nodes are available with `kubectl get nodes`

## Deployment 
- Customize the deployment in `opengatellm-stack/values.yaml`, for example the tag of the API version to deploy, rate limiting, API keys for the different deployed services (redis, elastic search, Qdrant, etc), ports, hardware configuration requested by each pod, etc.
- In `opengatellm-stack/values-secret.yaml`, replace the secrets and API keys with values of your choice.
- Create a namespace for the deployment `kubectl create namespace opengatellm`  
- From the `opengatellm-stack` folder, install the helm chart in the namespace : `helm install opengatellm-stack . -f values.yaml -f values-secrets.yaml --namespace opengatellm`
- Monitor the deployment via the kubernetes dashboard, or via a tool like `k9s`.
- If some components don't start, or are stuck in "Pending", check why with `kubectl describe <pod_name>`.
- If they start but remain in error, you can check the logs with `kubectl logs <pod_name>`
- The entire stack can take 15-20 minutes to deploy
- The "opengatellm" deployment will fail in a loop until the two deployments "embedding" and "vllm" are in "Running" status.
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
