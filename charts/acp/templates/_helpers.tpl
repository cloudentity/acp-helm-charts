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
app.kubernetes.io/name: {{ include "acp.name" . }}-workers
app.kubernetes.io/instance: {{ .Release.Name }}-workers
{{- end }}

{{- define "acp.faas.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Root.Release.Name }}-faas
app.kubernetes.io/environment: {{ .Environment }}
app.kubernetes.io/version: {{ .Version }}
{{- end }}

{{/*
Create the name of the acp service account to use
*/}}
{{- define "acp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the faas service account to use
*/}}
{{- define "faas.serviceAccountName" -}}
{{- if .Values.faas.serviceAccount.create }}
{{- default (print (include "acp.fullname" .) "-faas") .Values.faas.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.faas.serviceAccount.name }}
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

{{/*
Create mtls secret list
*/}}
{{- define "acp.mtls.secrets" -}}
{{- $list := list }}
{{- range .Values.ingressMtls.tlsSecrets }}
{{- $list = append $list ( printf "%s/%s" $.Release.Namespace .name ) }}
{{- end }}
{{- join "," $list }}
{{- end }}

{{/*
Create shared URL for Node or Rego environment.
*/}}
{{- define "acp.sharedEnvironmentUrl" -}}
  {{- $environmentType := index . "environmentType" }}
  {{- $rootContext := index . "root" }}
  {{- $kedaEnabled := $rootContext.Values.faas.environments.autoscaling.keda.enabled }}
  {{- $envCount := 0 }}
  {{- $singleEnvVersion := "" }}

  {{- /* Iterate over the environments to count how many are enabled and get the version of the single enabled environment if applicable. */}}
  {{- range $version, $details := index $rootContext.Values.faas.environments $environmentType }}
    {{- if $details.enabled }}
      {{- $envCount = add $envCount 1 }}
      {{- $singleEnvVersion = $version }}
    {{- end }}
  {{- end }}

  {{- /* Determine the version suffix based on the count of enabled environments. */}}
  {{- $versionSuffix := "" }}
  {{- if eq $envCount 1 }}
    {{- $versionSuffix = $singleEnvVersion }}
  {{- else }}
    {{- $versionSuffix = "{{envVersion}}" }}
  {{- end }}

  {{- /* Determine the port and proxy suffix based on whether Keda is enabled. */}}
  {{- $port := ternary $rootContext.Values.faas.environments.autoscaling.keda.port $rootContext.Values.faas.environments.settings.ports.http $kedaEnabled }}
  {{- $proxySuffix := ternary "" "-proxy" (not $kedaEnabled) }}

  {{- /* Construct the full URL. */}}
  {{-  "http://" }}{{ include "acp.fullname" $rootContext }}-faas-{{ $environmentType }}-v{{ $versionSuffix }}{{ $proxySuffix }}.{{ $rootContext.Values.faas.namespace.name }}:{{ $port }}
{{- end }}

