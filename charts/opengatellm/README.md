# opengatellm

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.6](https://img.shields.io/badge/AppVersion-0.3.6-informational?style=flat-square)

A Helm chart for OpenGateLLM

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://cloudnative-pg.github.io/charts | postgresql(cluster) | 0.3.1 |
| https://dandydeveloper.github.io/charts/ | redis(redis-ha) | 4.35.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| image.pullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` | Annotations for the gateway ingress |
| ingress.enabled | bool | `false` | Specifies whether an ingress for the api should be created |
| ingress.hosts | list | `[{"host":"api.example.com","paths":[{"path":"/"}]}]` | Hosts configuration for the api ingress, passed through the `tpl` function to allow templating |
| ingress.ingressClassName | string | `""` | Ingress Class Name. |
| ingress.labels | object | `{}` | Labels for the gateway ingress |
| ingress.tls | list | `[{"hosts":["api.example.com"],"secretName":"api-example-com-tls"}]` | TLS configuration for the gateway ingress. Hosts passed through the `tpl` function to allow templating |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| opengatellm.affinity | object | `{}` |  |
| opengatellm.annotations | object | `{}` |  |
| opengatellm.config | string | `"models: \n  {{ toYaml .Values.opengatellm.models | nindent 8 }}\n"` | Base config file for opengatellm. Contains Helm templates that are evaulated at install/upgrade. To modify the resulting configuration, either copy and alter 'opengatellm.config' as a whole or use the 'opengatellm.structuredConfig' to add and modify certain YAML elements. |
| opengatellm.containerSecurityContext | object | `{}` | The SecurityContext for API containers |
| opengatellm.dnsConfig | object | `{}` |  |
| opengatellm.env | list | `[]` |  |
| opengatellm.existingModelSecret | string | `""` | Secret loaded into env variable  Example:  existingModelSecret: "my-model-secrets"  You need to create secret before install/upgrade  apiVersion: v1 kind: Secret metadata:   name: my-models-secrets type: Opaque data:   ALBERT_URL: aHR0cHM6Ly9leGFtcGxlLmNvbS9hcGk=   ALBERT_KEY: YWRtaW4=  |
| opengatellm.existingSettingSecret | string | `""` | Secret loaded into env variable  Example:  existingModelSecret: "my-settings-secrets"  You need to create secret before install/upgrade  apiVersion: v1 kind: Secret metadata:   name: my-settings-secrets type: Opaque data:   MASTER_USERNAME: YWRtaW4=   MASTER_KEY: YWRtaW4=  |
| opengatellm.extraArgs | object | `{}` |  |
| opengatellm.extraContainers | list | `[]` |  |
| opengatellm.extraEnvFrom | list | `[]` |  |
| opengatellm.extraVolumeMounts | list | `[]` |  |
| opengatellm.extraVolumes | list | `[]` |  |
| opengatellm.image.pullPolicy | string | `"IfNotPresent"` |  |
| opengatellm.image.repository | string | `"ghcr.io/etalab-ia/opengatellm/api"` |  |
| opengatellm.initContainers | list | `[]` |  |
| opengatellm.models | list | `[]` | Models list to append to opengatellm.config  Example:  models: - name: albert   type: text-generation   providers:     - type: vllm       model_name: "gemma3:1b"       url: ${ALBERT_URL}       key: ${ALBERT_KEY} |
| opengatellm.nodeSelector | object | `{}` |  |
| opengatellm.persistence.subPath | string | `nil` |  |
| opengatellm.priorityClassName | string | `nil` | The name of the PriorityClass for API pods |
| opengatellm.probes | object | `{"liveness":{"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":60,"periodSeconds":30},"readiness":{"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":10,"periodSeconds":30}}` | API probes configuration |
| opengatellm.replicas | int | `1` |  |
| opengatellm.resources.limits.cpu | string | `"100m"` |  |
| opengatellm.resources.limits.memory | string | `"512Mi"` |  |
| opengatellm.resources.requests.cpu | string | `"100m"` |  |
| opengatellm.resources.requests.memory | string | `"512Mi"` |  |
| opengatellm.revisionHistoryLimit | string | `nil` |  |
| opengatellm.securityContext | object | `{}` | The SecurityContext for API deployment |
| opengatellm.service.port | int | `8000` |  |
| opengatellm.service.type | string | `"ClusterIP"` |  |
| opengatellm.serviceAccount.annotations | object | `{}` |  |
| opengatellm.serviceAccount.create | bool | `false` |  |
| opengatellm.serviceAccount.labels | object | `{}` |  |
| opengatellm.serviceAccount.name | string | `""` |  |
| opengatellm.structuredConfig | object | `{"dependencies":{"postgres":{"url":"${POSTGRES_URI}"},"redis":{"url":"redis://:test@${REDIS_HOST}:${REDIS_PORT:-6379}"}},"settings":{"log_level":"DEBUG"}}` | Additional structured values on top of the text based 'opengatellm.config'. Applied after the text based config is evaluated for templates. Enables adding and modifying YAML elements in the evaulated 'opengatellm.config'.  Example:  structuredConfig:   common:     example_key: example_value |
| opengatellm.terminationGracePeriodSeconds | int | `10` | GracePeriod of API container |
| opengatellm.tolerations | list | `[]` |  |
| opengatellm.topologySpreadConstraints | object | `{}` | topologySpreadConstraints |
| postgresql.cluster.affinity.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| postgresql.cluster.enableSuperuserAccess | bool | `true` |  |
| postgresql.cluster.initdb | object | `{"database":"api","encoding":"UTF8"}` | BootstrapInitDB is the configuration of the bootstrap process when initdb is used. |
| postgresql.cluster.instances | int | `1` | Number of instances |
| postgresql.cluster.logLevel | string | `"info"` |  |
| postgresql.cluster.monitoring.enabled | bool | `true` | Whether to enable monitoring |
| postgresql.cluster.monitoring.podMonitor.enabled | bool | `true` | Whether to enable the PodMonitor |
| postgresql.cluster.primaryUpdateMethod | string | `"switchover"` |  |
| postgresql.cluster.primaryUpdateStrategy | string | `"unsupervised"` |  |
| postgresql.cluster.resources.limits.cpu | string | `"250m"` |  |
| postgresql.cluster.resources.limits.memory | string | `"512Mi"` |  |
| postgresql.cluster.resources.requests.cpu | string | `"250m"` |  |
| postgresql.cluster.resources.requests.memory | string | `"512Mi"` |  |
| postgresql.cluster.storage.size | string | `"1Gi"` |  |
| postgresql.cluster.storage.storageClass | string | `""` |  |
| postgresql.cluster.walStorage.size | string | `"1Gi"` |  |
| postgresql.cluster.walStorage.storageClass | string | `""` |  |
| postgresql.clusterName | string | `"cluster-opengatellm"` | The original cluster name when used in backups. Also known as serverName. |
| postgresql.database | string | `"api"` | Name of the database used by the application. Default: `api`. |
| postgresql.enabled | bool | `false` | Install or not cnpg cluster Ensure CNPG Operator is installed on your cluster |
| postgresql.existingPostgresSecret | string | `""` | Configuration secret for an external PostgreSQL  existingPostgresSecret: "postgres-secret"  You need to create secret before install/upgrade  apiVersion: v1 kind: Secret metadata:   name: postgres-secret type: Opaque stringData:   POSTGRES_USER: api   POSTGRES_PASSWORD: changeme   POSTGRES_HOST: localhost   POSTGRES_PORT:5432   POSTGRES_URI: postgresql+asyncpg://api:changeme@localhost:5432/api  |
| postgresql.fullnameOverride | string | `"cluster-opengatellm"` |  |
| postgresql.mode | string | `"standalone"` |  |
| postgresql.pgBaseBackup.database | string | `"api"` |  |
| postgresql.pgBaseBackup.source.database | string | `"api"` |  |
| postgresql.version.postgresql | string | `"16"` | PostgreSQL major version to use |
| redis.auth | bool | `false` | Configures redis-ha with AUTH |
| redis.authKey | string | `"REDIS_PASSWORD"` | Defines the key holding the redis password in existing secret. |
| redis.containerSecurityContext | object | See [values.yaml] | Redis HA statefulset container-level security context |
| redis.enabled | bool | `true` | Install or not redis-ha cluster |
| redis.existingRedisSecret | string | `""` | Configuration secret for an external Redis  existingRedisSecret: "redis-secret"  You need to create secret before install/upgrade  apiVersion: v1 kind: Secret metadata:   name: redis-secret type: Opaque data:   REDIS_HOST: cmVkaXMub3BlbmdhdGVsbG0uc3ZjLmNsdXN0ZXIubG9jYWw=   REDIS_PORT: NjM3OQ==   REDIS_PASSWORD: Y2hhbmdlbWU=  |
| redis.existingSecret | string | `nil` | An existing secret containing a key defined by `authKey` that configures `requirepass` and `masterauth` in the conf parameters (Requires `auth: enabled`, cannot be used in conjunction with `.Values.redisPassword`) |
| redis.exporter | object | `{"enabled":false}` | Redis tag tag: "" # Prometheus redis-exporter sidecar |
| redis.exporter.enabled | bool | `false` | Enable Prometheus redis-exporter sidecar |
| redis.hardAntiAffinity | bool | `true` | Whether the Redis server pods should be forced to run on separate nodes. |
| redis.image | object | `{}` |  |
| redis.name | string | `"redis"` | Redis name |
| redis.persistentVolume.enabled | bool | `false` | Configures persistence on Redis nodes |
| redis.redis.config | object | See [values.yaml] | Any valid redis config options in this section will be applied to each server (see `redis-ha` chart) |
| redis.redis.config.save | string | `'""'` | Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred. `""`  is disabled |
| redis.redis.masterGroupName | string | `"opengatellm"` | Redis convention for naming the cluster group: must match `^[\\w-\\.]+$` and can be templated |
| redis.redisPassword | string | `""` |  |
| redis.sentinel.auth | bool | `false` |  |
| redis.sentinel.authKey | string | `"REDIS_PASSWORD"` | The key holding the sentinel password in an existing secret. |
| redis.sentinel.existingSecret | string | `""` | An existing secret containing a key defined by `sentinel.authKey` that configures `requirepass` in the conf parameters (Requires `sentinel.auth: enabled`, cannot be used in conjunction with `.Values.sentinel.password`) Supports templates like "{{ .Release.Name }}-sentinel-creds" |
| redis.sentinel.password | string | `nil` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
