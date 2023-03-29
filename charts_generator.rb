class ChartsGenerator
  def initialize(options)

    print "Operator Short name: "
    short_name = gets.chomp
    
    print "Namespaced [y/n]: "
    @namespaced = gets.chomp

    case @namespaced
    when 'y'
      print "Namespace: "
      options[:namespace] = gets.chomp
    when 'n'
      options[:namespace] = nil
    else
      puts "Invalid option, exiting..."
      exit 1
    end
    if @namespaced.eql?('y')
      @type = 'namespaced'
    else
      @type = 'clustered'
    end

    @options = options
    @values = <<~HEREDOC
                #{@namespaced.eql?('y') ? "namespace: #{options[:namespace]}\n": ''}replicaCount: 1
                image:
                  repository: ghcr.io/rubernetes/example
                  pullPolicy: IfNotPresent
                  tag: ex-7ebeb5b

                imagePullSecrets: []
                nameOverride: ""
                fullnameOverride: ""

                serviceAccount:
                  # Specifies whether a service account should be created
                  create: true
                  # Annotations to add to the service account
                  annotations: {}
                  # The name of the service account to use.
                  # If not set and create is true, a name is generated using the fullname template
                  name: "helm-#{@type}"

                rbac:
                  # -- Enable RBAC creation
                  enabled: true

                  resources: ["#{options[:crd_plural].downcase}"]

                podAnnotations: {}

                podSecurityContext: {}
                securityContext: {}

                service:
                  type: ClusterIP
                  port: 80

                resources: {}
                  # We usually recommend not to specify default resources and to leave this as a conscious
                  # choice for the user. This also increases chances charts run on environments with little
                  # resources, such as Minikube. If you do want to specify resources, uncomment the following
                  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
                  # limits:
                  #   cpu: 100m
                  #   memory: 128Mi
                  # requests:
                  #   cpu: 100m
                  #   memory: 128Mi

                autoscaling:
                  enabled: false
                  minReplicas: 1
                  maxReplicas: 100
                  targetCPUUtilizationPercentage: 80
                  # targetMemoryUtilizationPercentage: 80

                nodeSelector: {}

                tolerations: []

                affinity: {}


                ## Custom resource configuration
                crds:
                  # -- Install and upgrade CRDs
                  install: true
                  # -- Keep CRDs on chart uninstall
                  keep: true
                  # -- Annotations to be added to all CRDs
                  annotations: {}
                  # -- Group of the CRD
                  group: "#{options[:crd_group].downcase}"

                  # -- Custom resource properties
                  properties:
                    foo:
                      type: string
                    bar:
                      type: string
                  name: "#{options[:crd_plural].downcase}.#{options[:crd_group].downcase}"
                  
                  HEREDOC
    @chart = <<~HEREDOC
                apiVersion: v2
                version: 0.1.0
                name: helm-#{@type}
                appVersion: "1.16.0"
                description: A Helm chart for custum operator listener for #{@type} resources
                type: application
                HEREDOC

    @helm_ignore = <<~HEREDOC
                  # Patterns to ignore when building packages.
                  # This supports shell glob matching, relative path matching, and
                  # negation (prefixed with !). Only one pattern per line.
                  .DS_Store
                  # Common VCS dirs
                  .git/
                  .gitignore
                  .bzr/
                  .bzrignore
                  .hg/
                  .hgignore
                  .svn/
                  # Common backup files
                  *.swp
                  *.bak
                  *.tmp
                  *.orig
                  *~
                  # Various IDEs
                  .project
                  .idea/
                  *.tmproj
                  .vscode/
                  HEREDOC

    @crd = <<~HEREDOC
            {{- if .Values.crds.install }}
            apiVersion: apiextensions.k8s.io/v1
            kind: CustomResourceDefinition
            metadata:
              annotations:
                {{- if .Values.crds.keep }}
                "helm.sh/resource-policy": keep
                {{- end }}
                {{- with .Values.crds.annotations }}
                  {{- toYaml . | nindent 4 }}
                {{- end }}
              labels:
                {{- include "helm-#{@type}.labels" . | nindent 4 }}
              name: {{ .Values.crds.name }}#{@namespaced.eql?('y') ? "\n\tnamespace: {{ .Values.namespace }}": ''} 
            spec:
              group: {{ .Values.crds.group }}
              names:
                kind: "#{options[:name]}"
                listKind: "#{options[:name]}List
                plural: "#{options[:crd_plural].downcase}"
                shortNames:
                - "#{short_name}"
                - "#{short_name}s"
                singular: "#{options[:name].downcase}"
              scope: #{@namespaced.eql?('y') ? 'Namespaced' : 'Cluster'}
              versions:
              - name: "#{options[:crd_version].downcase}"
                schema:
                    openAPIV3Schema:
                      type: object
                      properties:
                        spec:
                          type: object
                          properties:
                            {{- with .Values.crds.properties }}
                            {{- toYaml . | nindent 16 }}
                            {{- end }}
                served: true
                storage: true
            {{- end }}
            HEREDOC

    @helpers = <<~HEREDOC
                  {{/*
                  Expand the name of the chart.
                  */}}
                  {{- define "helm-#{@type}.name" -}}
                  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
                  {{- end }}

                  {{/*
                  Create a default fully qualified app name.
                  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
                  If release name contains chart name it will be used as a full name.
                  */}}
                  {{- define "helm-#{@type}.fullname" -}}
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
                  {{- define "helm-#{@type}.chart" -}}
                  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
                  {{- end }}

                  {{/*
                  Common labels
                  */}}
                  {{- define "helm-#{@type}.labels" -}}
                  helm.sh/chart: {{ include "helm-#{@type}.chart" . }}
                  {{ include "helm-#{@type}.selectorLabels" . }}
                  {{- if .Chart.AppVersion }}
                  app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
                  {{- end }}
                  app.kubernetes.io/managed-by: {{ .Release.Service }}
                  {{- end }}

                  {{/*
                  Selector labels
                  */}}
                  {{- define "helm-#{@type}.selectorLabels" -}}
                  app.kubernetes.io/name: {{ include "helm-#{@type}.name" . }}
                  app.kubernetes.io/instance: {{ .Release.Name }}
                  {{- end }}

                  {{/*
                  Create the name of the service account to use
                  */}}
                  {{- define "helm-#{@type}.serviceAccountName" -}}
                  {{- if .Values.serviceAccount.create }}
                  {{- default (include "helm-#{@type}.fullname" .) .Values.serviceAccount.name }}
                  {{- else }}
                  {{- default "default" .Values.serviceAccount.name }}
                  {{- end }}
                  {{- end }}
                  HEREDOC
                      

    @deployment = <<~HEREDOC
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: {{ include "helm-#{@type}.fullname" . }}#{@namespaced.eql?('y') ? "\n\tnamespace: {{ .Values.namespace }}": ''} 
                      labels:
                        {{- include "helm-#{@type}.labels" . | nindent 4 }}
                    spec:
                      {{- if not .Values.autoscaling.enabled }}
                      replicas: {{ .Values.replicaCount }}
                      {{- end }}
                      selector:
                        matchLabels:
                          {{- include "helm-#{@type}.selectorLabels" . | nindent 6 }}
                      template:
                        metadata:
                          {{- with .Values.podAnnotations }}
                          annotations:
                            {{- toYaml . | nindent 8 }}
                          {{- end }}
                          labels:
                            {{- include "helm-#{@type}.selectorLabels" . | nindent 8 }}
                        spec:
                          {{- with .Values.imagePullSecrets }}
                          imagePullSecrets:
                            {{- toYaml . | nindent 8 }}
                          {{- end }}
                          serviceAccountName: {{ include "helm-#{@type}.serviceAccountName" . }}
                          securityContext:
                            {{- toYaml .Values.podSecurityContext | nindent 8 }}
                          containers:
                            - name: {{ .Chart.Name }}
                              securityContext:
                                {{- toYaml .Values.securityContext | nindent 12 }}
                              image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
                              imagePullPolicy: {{ .Values.image.pullPolicy }}
                              command: [ "ruby" ]
                              args: [ "#{options[:name].downcase}_controller.rb" ]
                              ports:
                                - name: http
                                  containerPort: {{ .Values.service.port }}
                                  protocol: TCP
                              resources:
                                {{- toYaml .Values.resources | nindent 12 }}
                          {{- with .Values.nodeSelector }}
                          nodeSelector:
                            {{- toYaml . | nindent 8 }}
                          {{- end }}
                          {{- with .Values.affinity }}
                          affinity:
                            {{- toYaml . | nindent 8 }}
                          {{- end }}
                          {{- with .Values.tolerations }}
                          tolerations:
                            {{- toYaml . | nindent 8 }}
                          {{- end }}
                    HEREDOC
                      

    @hpa = <<~HEREDOC
            {{- if .Values.autoscaling.enabled }}
            apiVersion: autoscaling/v2beta1
            kind: HorizontalPodAutoscaler
            metadata:
              name: {{ include "helm-#{@type}.fullname" . }}#{@namespaced.eql?('y') ? "\n\tnamespace: {{ .Values.namespace }}": ''}
              labels:
                {{- include "helm-#{@type}.labels" . | nindent 4 }}
            spec:
              scaleTargetRef:
                apiVersion: apps/v1
                kind: Deployment
                name: {{ include "helm-#{@type}.fullname" . }}
              minReplicas: {{ .Values.autoscaling.minReplicas }}
              maxReplicas: {{ .Values.autoscaling.maxReplicas }}
              metrics:
                {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
                - type: Resource
                  resource:
                    name: cpu
                    targetAverageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
                {{- end }}
                {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
                - type: Resource
                  resource:
                    name: memory
                    targetAverageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
                {{- end }}
            {{- end }}
            HEREDOC
                      

    @service = <<~HEREDOC
                apiVersion: v1
                kind: Service
                metadata:
                  name: {{ include "helm-#{@type}.fullname" . }}#{@namespaced.eql?('y') ? "\n\tnamespace: {{ .Values.namespace }}": ''}
                  labels:
                    {{- include "helm-#{@type}.labels" . | nindent 4 }}
                spec:
                  type: {{ .Values.service.type }}
                  ports:
                    - port: {{ .Values.service.port }}
                      targetPort: http
                      protocol: TCP
                      name: http
                  selector:
                    {{- include "helm-#{@type}.selectorLabels" . | nindent 4 }}
                HEREDOC
                      

    @service_account = <<~HEREDOC
                        {{- if .Values.serviceAccount.create -}}
                        apiVersion: v1
                        kind: ServiceAccount
                        metadata:
                          name: {{ include "helm-#{@type}.serviceAccountName" . }}
                          labels:
                            {{- include "helm-#{@type}.labels" . | nindent 4 }}
                          {{- with .Values.serviceAccount.annotations }}
                          annotations:
                            {{- toYaml . | nindent 4 }}
                          {{- end }}
                        {{- end }}
                        HEREDOC
                      

    @rbac_clustered = <<~HEREDOC
                      {{- if .Values.rbac.enabled }}
                      ---
                      apiVersion: rbac.authorization.k8s.io/v1
                      kind: ClusterRole
                      metadata:
                        name: {{ include "helm-clustered.fullname" . }}
                      rules:
                      - apiGroups: 
                        - {{ .Values.crds.group }}
                        resources: 
                        - {{ index .Values.rbac.resources 0 }}
                        verbs: ["*"]
                      ---
                      apiVersion: rbac.authorization.k8s.io/v1
                      kind: ClusterRoleBinding
                      metadata:
                        name: {{ include "helm-clustered.fullname" . }}-binding
                      roleRef: # points to the ClusterRole
                        apiGroup: rbac.authorization.k8s.io
                        kind: ClusterRole
                        name: {{ include "helm-clustered.fullname" . }} # name of ClusterRole
                      subjects: # points to the ServiceAccount
                      - kind: ServiceAccount
                        name: {{ include "helm-clustered.serviceAccountName" . }}
                        namespace: default # ns of service account
                      {{- end }}
                      HEREDOC

    @rbac_namespaced = <<~HEREDOC
                        {{- if .Values.rbac.enabled }}
                        ---
                        apiVersion: rbac.authorization.k8s.io/v1
                        kind: Role
                        metadata:
                          labels:
                            {{ include "helm-namespaced.labels" . | nindent 4 }}
                          name: {{ include "helm-namespaced.fullname" . }}
                          namespace: {{ .Values.namespace }}
                        rules:
                          - apiGroups:
                              - {{ .Values.crds.group }}
                            {{ with .Values.rbac.resources }}
                            resources:
                              {{- toYaml .| nindent 6 }}
                            {{- end }}
                            verbs:
                              - '*'
                        ---
                        apiVersion: rbac.authorization.k8s.io/v1
                        kind: RoleBinding
                        metadata:
                          labels:
                            {{ include "helm-namespaced.labels" . | nindent 4 }}
                          name: {{ include "helm-namespaced.fullname" . }}
                          namespace: {{ .Values.namespace }}
                        roleRef:
                          apiGroup: rbac.authorization.k8s.io
                          kind: Role
                          name: {{ include "helm-namespaced.fullname" . }}
                        subjects:
                        - kind: ServiceAccount
                          name: {{ include "helm-namespaced.serviceAccountName" . }}
                        {{- end }}
                        HEREDOC
  end
  def generate
    FileUtils.mkdir_p("helm-#{@type}") unless File.exist?("/helm-#{@type}")
    File.write("helm-#{@type}/values.yaml", @values)
    File.write("helm-#{@type}/Chart.yaml", @chart)
    File.write("helm-#{@type}/.helmignore", @helm_ignore)
    FileUtils.mkdir_p("helm-#{@type}/templates") unless File.exist?("/helm-#{@type}/templates")
    File.write("helm-#{@type}/templates/crd.yaml", @crd)
    File.write("helm-#{@type}/templates/_helpers.tpl", @helpers)
    File.write("helm-#{@type}/templates/deployment.yaml", @deployment)
    File.write("helm-#{@type}/templates/hpa.yaml", @hpa)
    File.write("helm-#{@type}/templates/service.yaml", @service)
    File.write("helm-#{@type}/templates/service_account.yaml", @service_account)
    if @namespaced.eql?('y')
      File.write("helm-namespaced/templates/rbac.yaml", @rbac_namespaced)
    else
      File.write("helm-clustered/templates/rbac.yaml", @rbac_clustered)
    end
  end
end