{{/*
Expand the name of the chart.
*/}}
{{- define "openbanking.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openbanking.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openbanking.labels" -}}
helm.sh/chart: {{ include "openbanking.chart" . }}
{{ include "openbanking.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openbanking.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openbanking.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openbanking.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openbanking.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "openbanking.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified bank name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "openbanking.bank.fullname" -}}
{{- if .Values.bank.fullnameOverride -}}
{{- .Values.bank.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.bank.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.bank.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create unified labels for openbanking components
*/}}
{{- define "openbanking.common.matchLabels" -}}
app: {{ template "openbanking.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "openbanking.common.metaLabels" -}}
chart: {{ template "openbanking.chart" . }}
heritage: {{ .Release.Service }}
{{- end -}}

{{- define "openbanking.bank.matchLabels" -}}
component: {{ .Values.bank.name | quote }}
{{ include "openbanking.common.matchLabels" . }}
{{- end -}}

{{- define "openbanking.bank.labels" -}}
{{ include "openbanking.bank.matchLabels" . }}
{{ include "openbanking.common.metaLabels" . }}
{{- end -}}

{{/*
Define the openbanking.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "openbanking.namespace" -}}
{{- if .Values.forceNamespace -}}
{{ printf "namespace: %s" .Values.forceNamespace }}
{{- else -}}
{{ printf "namespace: %s" .Release.Namespace }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the bank component
*/}}
{{- define "openbanking.serviceAccountName.bank" -}}
{{- if .Values.serviceAccounts.bank.create -}}
    {{ default (include "openbanking.bank.fullname" .) .Values.serviceAccounts.bank.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.bank.name }}
{{- end -}}
{{- end -}}