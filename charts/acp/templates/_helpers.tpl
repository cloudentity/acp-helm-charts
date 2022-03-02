{{/*
Expand the name of the chart.
*/}}
{{- define "acp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acp.fullname" -}}
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
{{- define "acp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acp.labels" -}}
helm.sh/chart: {{ include "acp.chart" . }}
{{ include "acp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "acp.workers.labels" -}}
helm.sh/chart: {{ include "acp.chart" . }}
{{ include "acp.workers.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "acp.workers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}-workers
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "acp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret config to use
*/}}
{{- define "acp.secretConfig" -}}
{{- if .Values.secretConfig.create }}
{{- default (include "acp.fullname" .) .Values.secretConfig.name }}
{{- else }}
{{- default "default" .Values.secretConfig.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the config to use
*/}}
{{- define "acp.configName" -}}
{{- if .Values.config.create }}
{{- default (include "acp.fullname" .) .Values.config.name }}
{{- else }}
{{- default "default" .Values.config.name }}
{{- end }}
{{- end }}

{{/*
Create the port number to use
*/}}
{{- define "acp.portNumber" -}}
{{- if .Values.tlsDisabled }}
{{- default 8080 }}
{{- else }}
{{- default 8443 }}
{{- end }}
{{- end }}
