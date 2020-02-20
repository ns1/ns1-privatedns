{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for data.
Truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "data.fullname" -}}
{{- if contains "data" .name -}}
{{ .name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .name "data" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for core.
Truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "core.fullname" -}}
{{- if contains "core" .name -}}
{{ .name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .name "core" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for dns.
Truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dns.fullname" -}}
{{- if contains "dns" .name -}}
{{ .name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .name "dns" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for dhcp.
Truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dhcp.fullname" -}}
{{- if contains "dhcp" .name -}}
{{ .name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .name "dhcp" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for xfr.
Truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "xfr.fullname" -}}
{{- if contains "xfr" .name -}}
{{ .name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .name "xfr" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for dist.
Truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dist.fullname" -}}
{{- if contains "dist" .name -}}
{{ .name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .name "dist" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
