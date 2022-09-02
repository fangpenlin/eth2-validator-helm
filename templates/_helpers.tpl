{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eth2-validator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eth2-validator.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "eth2-validator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "eth2-validator.labels" -}}
helm.sh/chart: {{ include "eth2-validator.chart" . }}
app.kubernetes.io/name: {{ include "eth2-validator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eth2-validator.geth.serviceAccountName" -}}
{{- if .Values.geth.serviceAccount.create -}}
    {{ default (printf "%s-geth" (include "eth2-validator.fullname" .)) .Values.geth.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.geth.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eth2-validator.beacon.serviceAccountName" -}}
{{- if .Values.beacon.serviceAccount.create -}}
    {{ default (printf "%s-beacon" (include "eth2-validator.fullname" .)) .Values.beacon.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.beacon.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eth2-validator.validator.serviceAccountName" -}}
{{- if .Values.validator.serviceAccount.create -}}
    {{ default (printf "%s-validator" (include "eth2-validator.fullname" .)) .Values.validator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.validator.serviceAccount.name }}
{{- end -}}
{{- end -}}
