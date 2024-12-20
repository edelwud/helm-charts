{{/*
Expand the name of the chart.
*/}}
{{- define "registry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "registry.fullname" -}}
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
{{- define "registry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "registry.labels" -}}
helm.sh/chart: {{ include "registry.chart" . }}
{{ include "registry.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "registry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "registry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "registry.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "registry.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "registry.configName" -}}
{{- if .Values.fullnameOverride }}
{{- printf "%s-config" .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "%s-config" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-config" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "registry.calculateConfig" -}}
{{ tpl (mergeOverwrite (tpl .Values.registry.config.unstructuredConfig . | fromYaml) .Values.registry.config.structuredConfig | toYaml) . }}
{{- end }}

{{- define "registry.configLog" }}
{{- if .Values.registry.log }}
log:
  {{- with .Values.registry.log.accessLog }}
  accesslog:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.registry.log.level }}
  level: {{ . }}
  {{- end }}
  {{- with .Values.registry.log.formatter }}
  formatter: {{ . }}
  {{- end }}
  {{- with .Values.registry.log.fields }}
  fields:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  {{ $smtp := .Values.registry.log.hooksSettings.smtpCredentials }}
  {{- with .Values.registry.log.hooksSettings.hooks }}
  hooks:
    {{ range $k := . }}
    - {{ merge . (dict "smtp" $smtp) | toYaml | nindent 6 }}
    {{ end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "registry.storage" }}
{{- if .Values.registry.storage }}
storage:
  {{ pick .Values.registry.storage .Values.registry.storage.driver | toYaml | nindent 2 }}
  {{- with .Values.registry.storage.maintenance }}
  maintenance:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.registry.storage.delete }}
  delete:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.registry.storage.cache }}
  cache:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.registry.storage.tag }}
  tag:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.registry.storage.redirect }}
  redirect:
    {{ toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}