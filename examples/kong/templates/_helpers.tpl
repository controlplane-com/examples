{{/*
Parse KONG_ADMIN_LISTEN ports
*/}}
{{- define "chart.parseKongAdminListen" -}}
{{- $portsList := list -}}
{{- range $part := splitList ", " .Values.kong.configurations.kong.KONG_ADMIN_LISTEN -}}
    {{- $port := splitList ":" $part | last -}}
    {{- $portsList = append $portsList $port -}}
{{- end -}}
{{- join "," $portsList -}}
{{- end -}}

{{/*
Parse KONG_ADMIN_GUI_LISTEN ports
*/}}
{{- define "chart.parseKongAdminGUIListen" -}}
{{- $portsList := list -}}
{{- range $part := splitList ", " .Values.kong.configurations.kong.KONG_ADMIN_GUI_LISTEN -}}
    {{- $port := splitList ":" $part | last -}}
    {{- $portsList = append $portsList $port -}}
{{- end -}}
{{- join "," $portsList -}}
{{- end -}}

{{/*
Parse KONG_PROXY_LISTEN ports
*/}}
{{- define "chart.parseKongProxyListen" -}}
{{- $portsList := list -}}
{{- range $part := splitList ", " .Values.kong.configurations.kong.KONG_PROXY_LISTEN -}}
    {{- $port := splitList ":" $part | last -}}
    {{- $portsList = append $portsList $port -}}
{{- end -}}
{{- join "," $portsList -}}
{{- end -}}
