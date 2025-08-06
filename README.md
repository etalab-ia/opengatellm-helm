This repository contains the helm chart to deploy OpenGateLLM and its components on Kubernetes.

You can check the official OpenGateLLM repository here: https://github.com/etalab-ia/OpenGateLLM/

## Deployment
- Create a kubernetes cluster with the provider of your choice. We provide tofu files to easily create an adequate cluster with an H100 on scaleway.
- To do so, run `tofu apply` from the `tofu/scaleway` folder
- In `opengatellm-stack/values.yaml`, replace the secrets and API key with values of your choice. You can also customize your deployment via this file, for example the tag of the API version to deploy, rate limiting, API keys for the different deployed services (redis, elastic search, Qdrant, etc), ports, hardware configuration requested by each pod, etc.
- From the `opengatellm-stack` folder, install the helm chart with the command `helm install opengatellm-stack .`
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
