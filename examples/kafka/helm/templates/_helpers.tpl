{{/*
Convert .Values.kafka.memory to appropriate JVM heap size settings.
*/}}
{{- define "kafka.heap.opts" -}}
{{- $memory := default "512Mi" .Values.kafka.memory }}
{{- $memoryInMi := 0 }}
{{- if hasSuffix "Gi" $memory }}
  {{- $value := trimSuffix "Gi" $memory | int }}
  {{- $memoryInMi = mul $value 1024 }}
{{- else if hasSuffix "Mi" $memory }}
  {{- $memoryInMi = trimSuffix "Mi" $memory | int }}
{{- end }}
'-Xmx{{ $memoryInMi }}m -Xms{{ $memoryInMi }}m'
{{- end }}
