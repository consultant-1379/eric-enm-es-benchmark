{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enm-es-benchmark.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-enm-es-benchmark.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{ define "eric-enm-es-benchmark.globals" }}
  {{- $globalDefaults := dict "cnivAgent" (dict "enabled" false) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "cnivAgent" (dict "name" "eric-oss-cniv" )) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "cnivAgent" (dict "port" "8080" )) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se" )) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret" "") -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{- define "eric-enm-es-benchmark.registry.url" -}}
{{- $registry := .Values.registry.url -}}
{{- if .Values.global -}}
    {{- if .Values.global.registry -}}
        {{- if .Values.global.registry.url -}}
            {{- $registry = .Values.global.registry.url -}}
        {{- end }}
    {{- end }}
{{- end }}
{{- $registry -}}
{{- end }}

{{- define "orchestrator.http.port" -}}
8080
{{- end -}}

{{/*
Paths to images
*/}}
{{- define "eric-enm-es-benchmark.initbenchimagepath" -}}
{{ include "eric-enm-es-benchmark.registry.url" . }}/{{ .Values.imageCredentials.repoPath }}/{{ .Values.images.initbench.name }}:{{ .Values.images.initbench.tag }}
{{- end }}

{{- define "eric-enm-es-benchmark.esbenchimagepath" -}}
{{ include "eric-enm-es-benchmark.registry.url" . }}/{{ .Values.imageCredentials.repoPath }}/{{ .Values.images.esbench.name }}:{{ .Values.images.esbench.tag }}
{{- end }}

{{- define "image.pullPolicy" -}}
{{- if .Values.image.pullPolicy -}}
{{ .Values.image.pullPolicy }}
{{- else -}}
IfNotPresent
{{- end -}}
{{- end -}}



{{- define "eric-enm-es-benchmark.cnivAgent.enabled" -}}
{{- $g := fromJson (include "eric-enm-es-benchmark.globals" .) -}}
{{- $g.cnivAgent.enabled }}
{{- end -}}

{{- define "eric-enm-es-benchmark.cnivAgent.name" -}}
{{- $g := fromJson (include "eric-enm-es-benchmark.globals" .) -}}
{{- $g.cnivAgent.name }}
{{- end -}}

{{- define "eric-enm-es-benchmark.cnivAgent.port" -}}
{{- $g := fromJson (include "eric-enm-es-benchmark.globals" .) -}}
{{- $g.cnivAgent.port }}
{{- end -}}

{{- define "eric-enm-es-benchmark.esbench.labels" -}}
app.kubernetes.io/name: {{ $.Chart.Name }}
job-name: {{ $.Chart.Name }}
{{- end }}

{{- define "eric-enm-es-benchmark.orchestrator.labels" -}}
app.kubernetes.io/name: {{ $.Chart.Name }}
app.kubernetes.io/component: es-orchestrator
job-name: {{ $.Chart.Name }}
benchmarkname: {{ $.Chart.Name }}
{{- if .Values.global -}}
  {{- if .Values.global.cnivAgent.enabled }}
    benchmarkgroup: {{ include "eric-enm-es-benchmark.benchmarkGroup.label" . }}
  {{- end }}
{{- end }}
{{- end }}




{{/*
Define PullSecret
*/}}
{{- define "eric-enm-es-benchmark.pullSecret" -}}
{{- $pullSecret := .Values.imageCredentials.pullSecret -}}
{{- if not (.Values.imageCredentials.pullSecret) -}}
  {{- if .Values.global -}}
      {{- if .Values.global.pullSecret -}}
          {{- $pullSecret = .Values.global.pullSecret }}
      {{- end }}
  {{- end }}
{{- end }}
{{- $pullSecret -}}
{{- end }}


{{- define "eric-enm-es-benchmark.benchmarkGroup.label" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.cnivAgent.enabled }}
      {{- range $groupmap := .Values.global.sequence -}}
        {{- range $group,$benchmarks := $groupmap -}}
          {{- range $bench := $benchmarks }}
            {{- if eq $.Chart.Name $bench }}
              {{- $label := print $group -}}
              {{- $label | lower | trunc 54 | trimSuffix "-" -}}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- $label := print "default" -}}
    {{- $label | lower | trunc 54 | trimSuffix "-" -}}
  {{- end }}
{{- end }}

{{/*
Common Storageclass name
*/}}
{{- define "eric-enm-es-benchmark.storageClass" -}}
{{- $storageClass := .Values.persistentVolumeClaim.storageClass.block -}}
{{- if .Values.global -}}
    {{- if .Values.global.persistentVolumeClaim -}}
        {{- if .Values.global.persistentVolumeClaim.storageClass -}}
            {{- if .Values.global.persistentVolumeClaim.storageClass.block -}}
                {{- $storageClass = .Values.global.persistentVolumeClaim.storageClass.block -}}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}
{{- $storageClass -}}
{{- end }}



