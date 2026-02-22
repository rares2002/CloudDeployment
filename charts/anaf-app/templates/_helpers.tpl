{{/*
Expand the name of the chart.
*/}}
{{- define "anaf-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "anaf-app.fullname" -}}
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
Create chart label.
*/}}
{{- define "anaf-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "anaf-app.labels" -}}
helm.sh/chart: {{ include "anaf-app.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Backend selector labels.
*/}}
{{- define "anaf-app.backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "anaf-app.name" . }}-backend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend selector labels.
*/}}
{{- define "anaf-app.frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "anaf-app.name" . }}-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL selector labels.
*/}}
{{- define "anaf-app.mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "anaf-app.name" . }}-mysql
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL service name (used by backend to connect).
*/}}
{{- define "anaf-app.mysql.serviceName" -}}
{{- printf "%s-mysql" (include "anaf-app.fullname" .) }}
{{- end }}
