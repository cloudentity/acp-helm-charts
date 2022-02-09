{{/*
Expand the name of the chart.
*/}}
{{- define "standalone-authorizer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "standalone-authorizer.fullname" -}}
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
{{- define "standalone-authorizer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "standalone-authorizer.labels" -}}
helm.sh/chart: {{ include "standalone-authorizer.chart" . }}
{{ include "standalone-authorizer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "standalone-authorizer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "standalone-authorizer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "standalone-authorizer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "standalone-authorizer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the client secret to use
*/}}
{{- define "standalone-authorizer.clientCredentialsName" -}}
{{- if .Values.clientCredentials.create }}
{{- default (include "standalone-authorizer.fullname" .) .Values.clientCredentials.name }}
{{- else }}
{{- default "default" .Values.clientCredentials.name }}
{{- end }}
{{- end }}
