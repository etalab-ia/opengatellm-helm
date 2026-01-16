# opengatellm-stack

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.5post2](https://img.shields.io/badge/AppVersion-0.3.5post2-informational?style=flat-square)

A Helm chart for OpenGateLLM Stack

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../opengatellm-core | opengatellm-core | 0.1.0 |
| https://helm.elastic.co | eck-operator | 3.2.0 |
| https://helm.elastic.co | eck-operator-crds | 3.2.0 |
| https://vllm-project.github.io/production-stack | vllm-stack | 0.1.8 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| eck-operator-crds | object | `{}` |  |
| eck-operator.config.validateStorageClass | bool | `false` |  |
| eck-operator.createClusterScopedResources | bool | `true` |  |
| eck-operator.installCRDs | bool | `false` |  |
| eck-operator.resources.limits.cpu | int | `1` |  |
| eck-operator.resources.limits.memory | string | `"1Gi"` |  |
| eck-operator.resources.requests.cpu | string | `"100m"` |  |
| eck-operator.resources.requests.memory | string | `"150Mi"` |  |
| eck-operator.webhook.enabled | bool | `false` |  |
| elasticsearch.enabled | bool | `true` |  |
| elasticsearch.persistence.enabled | bool | `true` |  |
| elasticsearch.persistence.size | string | `"8Gi"` |  |
| elasticsearch.replicas | int | `1` |  |
| elasticsearch.resources.limits.cpu | string | `"400m"` |  |
| elasticsearch.resources.limits.memory | string | `"4Gi"` |  |
| elasticsearch.resources.requests.cpu | string | `"100m"` |  |
| elasticsearch.resources.requests.memory | string | `"1Gi"` |  |
| elasticsearch.version | string | `"9.0.8"` |  |
| embeddings.config.model | string | `"BAAI/bge-m3"` |  |
| embeddings.config.port | int | `8000` |  |
| embeddings.enabled | bool | `true` |  |
| embeddings.image.pullPolicy | string | `"IfNotPresent"` |  |
| embeddings.image.repository | string | `"ghcr.io/huggingface/text-embeddings-inference"` |  |
| embeddings.image.tag | string | `"cpu-latest"` |  |
| embeddings.probes.liveness.enabled | bool | `false` |  |
| embeddings.probes.liveness.initialDelaySeconds | int | `240` |  |
| embeddings.probes.liveness.path | string | `"/health"` |  |
| embeddings.probes.liveness.periodSeconds | int | `30` |  |
| embeddings.probes.readiness.enabled | bool | `true` |  |
| embeddings.probes.readiness.initialDelaySeconds | int | `30` |  |
| embeddings.probes.readiness.path | string | `"/health"` |  |
| embeddings.probes.readiness.periodSeconds | int | `120` |  |
| embeddings.replicas | int | `1` |  |
| embeddings.resources.limits.cpu | string | `"4"` |  |
| embeddings.resources.limits.gpu | int | `0` |  |
| embeddings.resources.limits.memory | string | `"28Gi"` |  |
| embeddings.resources.requests.cpu | string | `"2"` |  |
| embeddings.resources.requests.gpu | int | `0` |  |
| embeddings.resources.requests.memory | string | `"16Gi"` |  |
| embeddings.service.port | int | `80` |  |
| embeddings.service.targetPort | int | `8000` |  |
| embeddings.service.type | string | `"ClusterIP"` |  |
| global.storage.storageClassName | string | `"sbs-default"` |  |
| huggingface.token | string | `"changeme"` |  |
| opengatellm-core.enabled | bool | `true` |  |
| opengatellm-core.opengatellm-core.gunicornArgs | string | `"--workers 4 --worker-connections 1000 --timeout 120 --keep-alive 75 --graceful-timeout 75 --log-config /home/opengatellm/logging/logging.conf"` |  |
| opengatellm-core.opengatellm-core.image.pullPolicy | string | `"IfNotPresent"` |  |
| opengatellm-core.opengatellm-core.image.repository | string | `"ghcr.io/etalab-ia/opengatellm/api"` |  |
| opengatellm-core.opengatellm-core.image.tag | string | `"0.3.6"` |  |
| opengatellm-core.opengatellm-core.logging.level | string | `"INFO"` |  |
| opengatellm-core.opengatellm-core.models[0].name | string | `"albert-testbed"` |  |
| opengatellm-core.opengatellm-core.models[0].providers[0].key | string | `"changeme"` |  |
| opengatellm-core.opengatellm-core.models[0].providers[0].model_name | string | `"gemma3:1b"` |  |
| opengatellm-core.opengatellm-core.models[0].providers[0].type | string | `"vllm"` |  |
| opengatellm-core.opengatellm-core.models[0].providers[0].url | string | `"http://albert-testbed.etalab.gouv.fr:8000"` |  |
| opengatellm-core.opengatellm-core.models[0].type | string | `"text-generation"` |  |
| opengatellm-core.opengatellm-core.models[1].name | string | `"mistralai/Mistral-Small-3.2-24B-Instruct-2506"` |  |
| opengatellm-core.opengatellm-core.models[1].providers[0].key | string | `"changeme"` |  |
| opengatellm-core.opengatellm-core.models[1].providers[0].model_name | string | `"mistralai/Mistral-Small-3.2-24B-Instruct-2506"` |  |
| opengatellm-core.opengatellm-core.models[1].providers[0].type | string | `"vllm"` |  |
| opengatellm-core.opengatellm-core.models[1].providers[0].url | string | `"http://opengatellm-router-service/"` |  |
| opengatellm-core.opengatellm-core.models[1].type | string | `"text-generation"` |  |
| opengatellm-core.opengatellm-core.models[2].dimensions | int | `1024` |  |
| opengatellm-core.opengatellm-core.models[2].name | string | `"BAAI/bge-m3"` |  |
| opengatellm-core.opengatellm-core.models[2].providers[0].key | string | `"changeme"` |  |
| opengatellm-core.opengatellm-core.models[2].providers[0].model_name | string | `"BAAI/bge-m3"` |  |
| opengatellm-core.opengatellm-core.models[2].providers[0].type | string | `"tei"` |  |
| opengatellm-core.opengatellm-core.models[2].providers[0].url | string | `"http://opengatellm-stack-embeddings/"` |  |
| opengatellm-core.opengatellm-core.models[2].type | string | `"text-embeddings-inference"` |  |
| opengatellm-core.opengatellm-core.probes.liveness.httpGet.path | string | `"/health"` |  |
| opengatellm-core.opengatellm-core.probes.liveness.httpGet.port | string | `"http"` |  |
| opengatellm-core.opengatellm-core.probes.liveness.initialDelaySeconds | int | `60` |  |
| opengatellm-core.opengatellm-core.probes.liveness.periodSeconds | int | `30` |  |
| opengatellm-core.opengatellm-core.probes.readiness.httpGet.path | string | `"/health"` |  |
| opengatellm-core.opengatellm-core.probes.readiness.httpGet.port | string | `"http"` |  |
| opengatellm-core.opengatellm-core.probes.readiness.initialDelaySeconds | int | `10` |  |
| opengatellm-core.opengatellm-core.probes.readiness.periodSeconds | int | `30` |  |
| opengatellm-core.opengatellm-core.replicas | int | `1` |  |
| opengatellm-core.opengatellm-core.service.port | int | `80` |  |
| opengatellm-core.opengatellm-core.service.targetPort | int | `8000` |  |
| opengatellm-core.opengatellm-core.service.type | string | `"ClusterIP"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.elasticsearch.hosts | string | `"http://opengatellm-elasticsearch-es-http:9200"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.postgres.connect_args.command_timeout | int | `60` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.postgres.connect_args.server_settings.statement_timeout | string | `"120s"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.postgres.echo | bool | `false` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.postgres.pool_size | int | `5` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.postgres.url | string | `"${POSTGRES_URI}"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.dependencies.redis.url | string | `"redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.api_url | string | `"http://opengatellm"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.app_title | string | `"OpenGateLLM"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.default_model | string | `""` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.encryption_key | string | `"changeme"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.postgres.url | string | `"postgresql+asyncpg://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/playground"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.proconnect_enabled | bool | `false` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.session_secret_key | string | `"changeme"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_accent_color | string | `"purple"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_appearance | string | `"light"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_gray_color | string | `"gray"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_has_background | bool | `true` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_panel_background | string | `"solid"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_radius | string | `"medium"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.playground.theme_scaling | string | `"100%"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.settings.log_level | string | `"INFO"` |  |
| opengatellm-core.opengatellm-core.structuredConfig.settings.vector_store_model | string | `"BAAI/bge-m3"` |  |
| opengatellm-core.postgresql.cluster.initdb.postInitApplicationSQL[0] | string | `"CREATE DATABASE playground WITH ENCODING 'UTF8';"` |  |
| playground.image.pullPolicy | string | `"IfNotPresent"` |  |
| playground.image.repository | string | `"ghcr.io/etalab-ia/opengatellm/playground"` |  |
| playground.image.tag | string | `"0.3.6"` |  |
| playground.probes.liveness.initialDelaySeconds | int | `10` |  |
| playground.probes.liveness.path | string | `"/"` |  |
| playground.probes.liveness.periodSeconds | int | `10` |  |
| playground.probes.readiness.initialDelaySeconds | int | `5` |  |
| playground.probes.readiness.path | string | `"/"` |  |
| playground.probes.readiness.periodSeconds | int | `10` |  |
| playground.replicas | int | `1` |  |
| playground.service.port | int | `80` |  |
| playground.service.targetPort | int | `8501` |  |
| playground.service.type | string | `"ClusterIP"` |  |
| vllm-stack.enabled | bool | `true` |  |
| vllm-stack.routerSpec.resources.limits.memory | string | `"2Gi"` |  |
| vllm-stack.routerSpec.resources.requests.cpu | string | `"400m"` |  |
| vllm-stack.routerSpec.resources.requests.memory | string | `"1Gi"` |  |
| vllm-stack.routerSpec.servicePort | int | `80` |  |
| vllm-stack.routerSpec.serviceType | string | `"ClusterIP"` |  |
| vllm-stack.servingEngineSpec.enableEngine | bool | `true` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].hf_token.secretKey | string | `"token"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].hf_token.secretName | string | `"huggingface-token"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].imagePullPolicy | string | `"IfNotPresent"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].limitCPU | string | `"22"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].limitMemory | string | `"230G"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].modelURL | string | `"mistralai/Mistral-Small-3.2-24B-Instruct-2506"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].name | string | `"mistral-small"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].pvcAccessMode[0] | string | `"ReadWriteOnce"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].pvcStorage | string | `"230Gi"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].replicaCount | int | `1` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].repository | string | `"vllm/vllm-openai"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].requestCPU | int | `20` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].requestGPU | int | `1` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].requestMemory | string | `"200G"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].shmSize | string | `"32Gi"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].storageClass | string | `"sbs-default"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].tag | string | `"v0.11.0"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.enablePrefixCaching | bool | `false` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[0] | string | `"--tokenizer_mode"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[1] | string | `"mistral"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[2] | string | `"--config_format"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[3] | string | `"mistral"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[4] | string | `"--load_format"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[5] | string | `"mistral"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[6] | string | `"--tool-call-parser"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[7] | string | `"mistral"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.extraArgs[8] | string | `"--enable-auto-tool-choice"` |  |
| vllm-stack.servingEngineSpec.modelSpec[0].vllmConfig.tensorParallelSize | int | `1` |  |
| vllm-stack.servingEngineSpec.vllmApiKey | string | `"changeme"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
