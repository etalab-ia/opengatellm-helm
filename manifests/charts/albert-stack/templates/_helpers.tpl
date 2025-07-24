{{/* Generate basic labels */}}
{{- define "opengatellm-stack.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{/* Component labels */}}
{{- define "opengatellm-stack.componentLabels" -}}
{{- include "opengatellm-stack.labels" . }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{/* Selector labels */}}
{{- define "opengatellm-stack.selectorLabels" -}}
app: {{ .name }}
{{- end -}}