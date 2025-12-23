{{/*
Expand the name of the chart.
*/}}
{{- define "opengatellm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opengatellm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opengatellm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opengatellm.labels" -}}
helm.sh/chart: {{ include "opengatellm.chart" . }}
{{ include "opengatellm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opengatellm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opengatellm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opengatellm.serviceAccountName" -}}
{{- if .Values.opengatellm.serviceAccount.create }}
{{- default (include "opengatellm.fullname" .) .Values.opengatellm.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.opengatellm.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Calculate the config from structured and unstructured text input
*/}}
{{- define "opengatellm.calculatedConfig" -}}
{{ tpl (mergeOverwrite (include "opengatellm.unstructuredConfig" . | fromYaml) .Values.opengatellm.structuredConfig | toYaml) . }}
{{- end -}}

{{/*
Calculate the config from the unstructured text input
*/}}
{{- define "opengatellm.unstructuredConfig" -}}
{{ include (print $.Template.BasePath "/_config-render.tpl") . }}
{{- end -}}

{{/*
The volume to mount for opengatellm configuration
*/}}
{{- define "opengatellm.configVolume" -}}
{{- if eq .Values.configStorageType "Secret" -}}
secret:
  secretName: {{ tpl .Values.externalConfigSecretName . }}
{{- else if eq .Values.configStorageType "ConfigMap" -}}
configMap:
  name: {{ tpl .Values.externalConfigSecretName . }}
  items:
    - key: "config.yml"
      path: "config.yml"
{{- end -}}
{{- end -}}

{{- define "opengatellm.config.checksum" -}}
checksum/config: {{ include (print .Template.BasePath "/opengatellm-configmap.yaml") . | sha256sum }}
{{- end -}}