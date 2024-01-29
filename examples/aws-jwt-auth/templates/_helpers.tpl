{{/*
Expand the name of the chart.
*/}}
{{- define "aws-jwt-auth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aws-jwt-auth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aws-jwt-auth.tags" -}}
helm.sh/chart: {{ include "aws-jwt-auth.chart" . }}
{{ include "aws-jwt-auth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.cpln.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.cpln.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aws-jwt-auth.selectorLabels" -}}
app.cpln.io/name: {{ include "aws-jwt-auth.name" . }}
app.cpln.io/instance: {{ .Release.Name }}
{{- end }}


