{{/*
Expand the name of the chart.
*/}}
{{- define "acp-cd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acp-cd.fullname" -}}
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
{{- define "acp-cd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acp-cd.labels" -}}
helm.sh/chart: {{ include "acp-cd.chart" . }}
{{ include "acp-cd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acp-cd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acp-cd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the client secret to use
*/}}
{{- define "acp-cd.clientCredentialsName" -}}
{{- if .Values.clientCredentials.create }}
{{- default (include "acp-cd.fullname" .) .Values.clientCredentials.name }}
{{- else }}
{{- default "default" .Values.clientCredentials.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the config to use
*/}}
{{- define "acp-cd.configName" -}}
{{- if .Values.config.create }}
{{- default (include "acp-cd.fullname" .) .Values.config.name }}
{{- else }}
{{- default "default" .Values.config.name }}
{{- end }}
{{- end }}

