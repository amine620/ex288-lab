---
name: openshift-patterns
description: OpenShift workload patterns, SCC, Routes, ImageStreams, BuildConfigs, S2I, Templates, Tekton, RBAC, probes, resource management, and oc debugging for production-grade OpenShift deployments.
metadata:
  origin: EX288 Training — Amine
---

# OpenShift Patterns

Production-grade OpenShift patterns for deploying, building, securing, and debugging workloads on OpenShift Container Platform 4.x.

> **Key difference from vanilla K8s:** OpenShift adds Security Context Constraints (SCC), Routes, ImageStreams, BuildConfigs, S2I, Templates, and a hardened default security posture. Every pattern here accounts for these additions.

---

## When to Activate

- Writing OpenShift manifests (Deployments, Routes, BuildConfigs, ImageStreams, Templates)
- Configuring SCC, ServiceAccounts, RBAC in OpenShift context
- Building apps via S2I, BuildConfig, or binary builds
- Setting up Routes (edge/passthrough/reencrypt) instead of Ingress
- Debugging CrashLoopBackOff, ImagePullBackOff, SCC violations, build failures
- Creating or processing OpenShift Templates with parameters
- Setting up Tekton Pipelines on OpenShift
- Configuring health probes, resource limits, HPA on OpenShift
- Reviewing OpenShift YAML for security or correctness

---

## When to Use

> Same as **When to Activate** above. Use this skill any time you are writing, reviewing, or debugging OpenShift workloads — especially when SCC, Routes, ImageStreams, or BuildConfigs are involved.

---

## Table of Contents

| Task | Section |
|---|---|
| Full production Deployment YAML | [Core Workload Patterns](#core-workload-patterns) |
| SCC — the most OpenShift-specific topic | [Security Context Constraints](#security-context-constraints-scc) |
| Routes vs Ingress | [Routes](#routes) |
| ImageStreams + Build triggers | [ImageStreams](#imagestreams) |
| S2I + BuildConfig | [Builds](#builds--s2i--buildconfig) |
| Templates + Parameters | [Templates](#templates) |
| Probes | [Probes](#probes) |
| RBAC + ServiceAccounts | [RBAC](#rbac) |
| ConfigMaps + Secrets | [ConfigMaps and Secrets](#configmaps-and-secrets) |
| Resource management | [Resources](#resource-management) |
| Tekton Pipelines | [Tekton](#tekton-pipelines) |
| HPA + PDB | [Autoscaling](#autoscaling) |
| oc debugging cheatsheet | [Debugging](#oc-debugging-cheatsheet) |
| Anti-patterns | [Anti-patterns](#anti-patterns) |
| Checklist | [Checklist](#best-practices-checklist) |

---

## Core Workload Patterns

### Deployment — Production Template (OpenShift)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-project         # OpenShift: namespace = project
  labels:
    app: my-app
    version: "1.0.0"
  annotations:
    # ImageStream trigger — auto-update image when ImageStream tag changes
    image.openshift.io/triggers: >
      [{"from":{"kind":"ImageStreamTag","name":"my-app:latest","namespace":"my-project"},
        "fieldPath":"spec.template.spec.containers[?(@.name==\"my-app\")].image"}]
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: my-app
        version: "1.0.0"
    spec:
      # OpenShift: always use a dedicated ServiceAccount, never default
      serviceAccountName: my-app-sa

      # OpenShift: restricted-v2 SCC enforces runAsNonRoot automatically
      # Only set securityContext if you need specific UID or fsGroup
      securityContext:
        runAsNonRoot: true      # Enforced by restricted-v2 anyway — explicit is better
        fsGroup: 1001           # Required for volume ownership

      terminationGracePeriodSeconds: 30

      containers:
        - name: my-app
          # OpenShift: reference ImageStream digest, not :latest tag
          image: ' '            # Filled by ImageStream trigger at deploy time
          imagePullPolicy: Always

          ports:
            - containerPort: 8080
              protocol: TCP

          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"

          # OpenShift: container securityContext must comply with assigned SCC
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
            # Do NOT set runAsUser: 0 unless using anyuid SCC explicitly

          startupProbe:
            httpGet:
              path: /health
              port: 8080
            failureThreshold: 30
            periodSeconds: 5

          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            periodSeconds: 30
            failureThreshold: 3

          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            periodSeconds: 10
            failureThreshold: 2

          envFrom:
            - configMapRef:
                name: my-app-config
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: my-app-secrets
                  key: db-password

          volumeMounts:
            - name: tmp
              mountPath: /tmp

      volumes:
        - name: tmp
          emptyDir: {}
```

---

## Security Context Constraints (SCC)

> **OpenShift only — no equivalent in vanilla K8s.**
> SCC is an admission controller that decides whether a pod is allowed to run based on its security requirements. It is the single most important OpenShift-specific topic.

### Default SCCs — Know These Cold

```
oc get scc
```

| SCC | Who Uses It | What It Allows |
|---|---|---|
| `restricted-v2` | Default for all pods | Non-root only, no host access, limited capabilities |
| `anyuid` | Apps needing specific UID (e.g. Docker Hub images) | Any UID including root (0) |
| `hostnetwork` | System components needing host network | Host network + ports |
| `hostmount-anyuid` | Apps needing host filesystem mounts | Host path + any UID |
| `privileged` | System-level only | Everything — never use for app workloads |
| `nonroot` | Non-root but any non-zero UID | Any UID except 0 |

### How OpenShift Assigns SCC to a Pod

```
Pod created
    │
    ▼
Admission controller checks pod's security requirements
    │
    ▼
Finds ServiceAccount → checks which SCCs are bound to it
    │
    ▼
Picks the LEAST permissive SCC that satisfies the pod's requirements
    │
    ▼
Annotates pod: openshift.io/scc: <chosen-scc>
    │
    ▼
Pod allowed or rejected
```

### Check Which SCC a Pod is Using

```bash
oc get pod <pod-name> -o yaml | grep "openshift.io/scc"
# Output: openshift.io/scc: restricted-v2
```

### Assign SCC to ServiceAccount (Correct Pattern)

```bash
# Step 1 — Create dedicated ServiceAccount
oc create sa my-app-sa -n my-project

# Step 2 — Assign minimum required SCC to SA
oc adm policy add-scc-to-user anyuid -z my-app-sa -n my-project
#                               │      │  │
#                               │      │  └── SA name
#                               │      └── -z = serviceaccount (not a human user)
#                               └── SCC name

# Step 3 — Wire SA to Deployment
oc set serviceaccount deployment/my-app my-app-sa

# Step 4 — Verify
oc get pod <new-pod> -o yaml | grep "openshift.io/scc"
```

### SCC Decision Table — Which SCC to Use

| Situation | Minimum SCC | Why |
|---|---|---|
| App runs as non-root, no special needs | `restricted-v2` | Default — no action needed |
| Docker Hub image (e.g. nginx, mysql) runs as root | `anyuid` | Allows any UID including 0 |
| App needs specific non-zero UID | `nonroot` | Less permissive than anyuid |
| App needs host network (e.g. node exporter) | `hostnetwork` | Allows host networking |
| App needs host path mounts | `hostmount-anyuid` | Allows hostPath volumes |
| NEVER use this for apps | `privileged` | Too permissive — security risk |

### Most Common SCC Error

```bash
# Error you will see:
Error creating: pods "my-app-xxx" is forbidden:
unable to validate against any security context constraint: 
[spec.containers[0].securityContext.runAsUser: Invalid value: 0: ...]

# Fix:
oc adm policy add-scc-to-user anyuid -z my-app-sa -n my-project
oc set serviceaccount deployment/my-app my-app-sa
```

### Why Docker Hub Images Fail on OpenShift

```
Docker Hub nginx:latest
    └── Dockerfile: USER root (or no USER = root by default)
    └── Binds to port 80 (privileged port)
    └── OpenShift restricted-v2: runAsUser MustRunAsNonRoot → BLOCKED

OpenShift-compatible nginx (bitnami/nginx or ubi8/nginx)
    └── Runs as UID 1001
    └── Binds to port 8080
    └── Passes restricted-v2 → ALLOWED
```

---

## Routes

> **OpenShift only.** Routes replace Ingress in OpenShift. HAProxy router (in `openshift-ingress` namespace) reads Route resources and forwards traffic.

### Route Types

```yaml
# Edge — TLS terminated at HAProxy, plain HTTP to pod
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app
spec:
  host: my-app-my-project.apps-crc.testing   # Auto-generated if omitted
  to:
    kind: Service
    name: my-app
    weight: 100
  port:
    targetPort: 8080
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect   # HTTP → HTTPS redirect
```

```yaml
# Passthrough — TLS all the way to pod (pod handles TLS)
spec:
  tls:
    termination: passthrough
  # No TLS cert needed on route — pod handles its own cert
```

```yaml
# Re-encrypt — TLS to HAProxy, re-encrypted TLS to pod
spec:
  tls:
    termination: reencrypt
    destinationCACertificate: |   # CA cert to verify pod's cert
      -----BEGIN CERTIFICATE-----
      ...
```

### Create Route via CLI

```bash
# Expose a service as a route (edge TLS)
oc expose svc/my-app
# Auto-generates: my-app-<project>.apps-<cluster-domain>

# Custom hostname
oc expose svc/my-app --hostname=myapp.example.com

# Add TLS after creation
oc patch route my-app -p '{"spec":{"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}'

# Verify route
oc get route my-app
oc describe route my-app
```

### Route vs Ingress

| | OpenShift Route | Kubernetes Ingress |
|---|---|---|
| API | `route.openshift.io/v1` | `networking.k8s.io/v1` |
| Controller | HAProxy (pre-installed) | You install (nginx, traefik, etc.) |
| TLS modes | edge, passthrough, reencrypt | terminate or passthrough |
| DNS | Auto-generated wildcard | Manual configuration |
| Works in OpenShift | ✅ Native | ✅ Also works (but Route preferred) |

---

## ImageStreams

> OpenShift abstraction layer between a logical image name and an immutable SHA256 digest in the registry.

### Key Concepts

```
ImageStream (my-app)
    └── tag: latest
          └── items[0].image = sha256:abc123...  ← immutable digest

Deployment
    └── spec.containers[0].image = 
        image-registry.openshift-image-registry.svc:5000/my-project/my-app@sha256:abc123...
```

### Create ImageStream

```bash
# Auto-created by oc new-app or BuildConfig output
# Or create manually:
oc create imagestream my-app

# Import external image into ImageStream
oc import-image my-app --from=docker.io/nginx:latest --confirm

# Check ImageStream tags and digests
oc get imagestream my-app -o yaml
oc describe imagestream my-app
```

### ImageStream Triggers

```bash
# View triggers on a deployment
oc set triggers deployment/my-app

# Add ImageChange trigger
oc set triggers deployment/my-app \
  --from-image=my-project/my-app:latest \
  -c my-app

# Remove all triggers (for GitOps — let ArgoCD control deployments)
oc set triggers deployment/my-app --remove-all
```

### Tag vs Digest

| | Tag (`:latest`) | Digest (`sha256:...`) |
|---|---|---|
| Mutable | ✅ Yes — can point to different images | ❌ No — always same image |
| Reproducible | ❌ No | ✅ Yes |
| Used in Deployment | After trigger resolves | Stored directly |
| Safe for production | ❌ Never use :latest in prod | ✅ Always pin to digest |

---

## Builds — S2I + BuildConfig

### S2I (Source-to-Image)

```
S2I Build Flow:
oc new-app nodejs~https://github.com/org/repo.git
    │
    ├── BuildConfig created (the recipe)
    │
    ├── Build pod starts (myapp-1-build)
    │     ├── Pulls nodejs builder image from openshift namespace
    │     ├── Clones Git repo
    │     ├── Runs assemble script (installs deps, builds app)
    │     └── Produces final image
    │
    ├── Image pushed to internal registry
    │     └── image-registry.openshift-image-registry.svc:5000/<ns>/<name>
    │
    ├── ImageStream tag updated → new SHA256
    │
    └── ImageChange trigger fires → Deployment updated → New pod
```

### BuildConfig — Full Example

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: my-app
spec:
  source:
    type: Git
    git:
      uri: https://github.com/org/repo.git
      ref: main                   # Branch, tag, or commit
    contextDir: /app              # Subdirectory if monorepo

  strategy:
    type: Source                  # S2I strategy
    sourceStrategy:
      from:
        kind: ImageStreamTag
        namespace: openshift      # Shared builder images live here
        name: nodejs:latest       # Builder image
      env:
        - name: NPM_MIRROR
          value: https://registry.npmjs.org

  output:
    to:
      kind: ImageStreamTag
      name: my-app:latest         # Where to push the built image

  triggers:
    - type: ConfigChange          # Rebuild when BuildConfig changes
    - type: ImageChange           # Rebuild when builder image updates
      imageChange: {}
    - type: GitHub                # Webhook trigger
      github:
        secret: my-webhook-secret

  postCommit:                     # Build hook — runs after build, before push
    script: "npm test"            # ⚠️ EX288 exam objective
```

### Build Commands

```bash
# Trigger a new build manually
oc start-build my-app

# Follow build logs live
oc logs -f buildconfig/my-app
oc logs -f build/my-app-1

# List all builds
oc get builds

# List build configs
oc get bc

# Cancel a running build
oc cancel-build my-app-1

# Binary build — push local artifact
oc start-build my-app --from-dir=./build/ --follow
oc start-build my-app --from-file=./app.jar --follow
```

### Build Hooks (EX288 Exam Objective)

```yaml
# postCommit hook — runs a script AFTER build, BEFORE image push
# If script fails → build fails → image NOT pushed → deployment NOT updated
postCommit:
  script: "npm test"              # Simple script

# Or with args:
postCommit:
  command: ["/bin/sh"]
  args: ["-c", "npm test && npm run lint"]
```

```bash
# Add hook via CLI
oc set build-hook bc/my-app --post-commit --script="npm test"

# Test the hook
oc start-build my-app --follow
# Watch for: "Running post commit hook..."
```

### Build Troubleshooting

```bash
# Build stuck or failing
oc get builds                             # Check status
oc logs build/my-app-1                    # Full build log
oc describe build my-app-1               # Events + failure reason

# Builder image pull fails
oc get imagestream -n openshift | grep nodejs   # Check builder exists
oc adm policy add-scc-to-user registry-viewer \
  system:serviceaccount:<ns>:default -n openshift  # Fix auth

# Git clone fails
oc describe build my-app-1 | grep -A5 "Error"
# Check: proxy settings, Git URL, credentials

# Build pod OOMKilled
oc describe build my-app-1 | grep -i memory
# Fix: increase build pod resources in BuildConfig
```

---

## Templates

### Template Structure

```yaml
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: my-app-template
  namespace: openshift              # Global scope: accessible from all projects
  annotations:
    description: "Deploy my app with PostgreSQL"
    tags: "nodejs,postgresql"
    openshift.io/display-name: "My App"

parameters:
  - name: APP_NAME
    displayName: Application Name
    value: myapp                    # Default value
    required: true

  - name: GIT_REPO
    displayName: Git Repository URL
    required: true                  # No default — user must provide

  - name: DB_PASSWORD
    displayName: Database Password
    generate: expression            # Auto-generate if not provided
    from: "[a-zA-Z0-9]{16}"
    required: true

  - name: REPLICAS
    displayName: Replica Count
    value: "1"                      # Always string in parameters

objects:
  - apiVersion: image.openshift.io/v1
    kind: ImageStream
    metadata:
      name: ${APP_NAME}             # ${PARAM} for string substitution

  - apiVersion: build.openshift.io/v1
    kind: BuildConfig
    metadata:
      name: ${APP_NAME}
    spec:
      source:
        git:
          uri: ${GIT_REPO}
      strategy:
        type: Source
        sourceStrategy:
          from:
            kind: ImageStreamTag
            namespace: openshift
            name: nodejs:latest
      output:
        to:
          kind: ImageStreamTag
          name: ${APP_NAME}:latest

  - apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ${APP_NAME}
    spec:
      replicas: ${{REPLICAS}}       # ${{PARAM}} for numeric values
      selector:
        matchLabels:
          app: ${APP_NAME}
      template:
        metadata:
          labels:
            app: ${APP_NAME}
        spec:
          containers:
            - name: ${APP_NAME}
              image: ' '            # Filled by ImageStream trigger
              ports:
                - containerPort: 8080

  - apiVersion: v1
    kind: Service
    metadata:
      name: ${APP_NAME}
    spec:
      selector:
        app: ${APP_NAME}
      ports:
        - port: 8080
          targetPort: 8080

  - apiVersion: route.openshift.io/v1
    kind: Route
    metadata:
      name: ${APP_NAME}
    spec:
      to:
        kind: Service
        name: ${APP_NAME}
      port:
        targetPort: 8080
      tls:
        termination: edge
        insecureEdgeTerminationPolicy: Redirect

  - apiVersion: v1
    kind: Secret
    metadata:
      name: ${APP_NAME}-db-creds
    type: Opaque
    stringData:                     # stringData auto-encodes to base64
      password: ${DB_PASSWORD}
```

### Template Commands

```bash
# Process local template and apply
oc process -f my-template.yaml \
  -p APP_NAME=myapp \
  -p GIT_REPO=https://github.com/org/repo.git \
  | oc apply -f -

# Process cluster-stored template
oc process openshift/nodejs-postgresql-example \
  -p NAME=myapp \
  | oc apply -f -

# Store template in cluster (openshift ns = global)
oc create -f my-template.yaml -n openshift

# Deploy from cluster-stored template
oc new-app --template=my-app-template \
  -p APP_NAME=myapp \
  -p GIT_REPO=https://github.com/org/repo.git

# List available templates
oc get templates -n openshift

# Discover template parameters
oc get template nodejs-postgresql-example -n openshift -o yaml | grep -A8 "parameters:"
oc process --parameters openshift/nodejs-postgresql-example
```

### Template Gotchas

```bash
# ⚠️ generate: expression creates NEW password on every oc process call
# If you re-apply, Secret gets new password, PostgreSQL keeps old one → auth failure
# Fix: always pass DB_PASSWORD explicitly on re-apply
oc process -f template.yaml -p DB_PASSWORD=myFixedPassword123 | oc apply -f -

# ⚠️ postgresql-persistent template auto-creates its OWN Secret named "postgresql"
# with keys: database-user, database-password, database-name (NOT POSTGRESQL_*)
# Check what the template actually creates before adding your own Secret
oc get template postgresql-persistent -n openshift -o yaml | grep -A3 "Secret"

# ⚠️ ${{NUMERIC}} vs ${STRING}
replicas: ${{REPLICAS}}    # Integer — use ${{}}
name: ${APP_NAME}          # String — use ${}
```

---

## Probes

### Decision Table

| Probe | Failure Action | Use For |
|---|---|---|
| `startupProbe` | Kills container if slow to start | Slow-starting apps (JVM, Python loading models) |
| `livenessProbe` | Restarts container | Deadlock, hung process, memory leak |
| `readinessProbe` | Removes from Service endpoints | Temporary unavailability, DB reconnect, not ready yet |

### Correct Pattern

```yaml
# startupProbe covers slow startup window
# liveness + readiness take over after startup succeeds
startupProbe:
  httpGet:
    path: /health
    port: 8080
  failureThreshold: 30    # 30 × 5s = 150s max startup time
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /health          # Same endpoint — is the process alive?
    port: 8080
  periodSeconds: 30
  failureThreshold: 3      # 3 × 30s = 90s before restart

readinessProbe:
  httpGet:
    path: /ready           # Different endpoint — checks DB, cache, dependencies
    port: 8080
  periodSeconds: 10
  failureThreshold: 2      # Faster — remove from rotation quickly if unhealthy
```

### Probe Types

```yaml
# HTTP GET — most common for web apps
livenessProbe:
  httpGet:
    path: /health
    port: 8080
    httpHeaders:
      - name: Authorization
        value: Bearer mytoken

# TCP Socket — for non-HTTP services (databases, message brokers)
livenessProbe:
  tcpSocket:
    port: 5432

# Exec — run a command inside the container
livenessProbe:
  exec:
    command:
      - /bin/sh
      - -c
      - "pg_isready -U postgres"
```

### Probe Anti-patterns

```yaml
# BAD: initialDelaySeconds without startupProbe — race condition
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 60   # Arbitrary wait — use startupProbe instead

# BAD: Same endpoint for liveness and readiness doing the same check
# readinessProbe should check dependencies (DB, cache)
# livenessProbe should only check if process is alive

# BAD: Too aggressive liveness probe — causes restart loops
livenessProbe:
  periodSeconds: 5
  failureThreshold: 1       # 1 failure = restart — too sensitive
```

---

## RBAC

### OpenShift RBAC = Kubernetes RBAC + SCC Binding

```bash
# OpenShift adds SCC binding on top of standard K8s RBAC
# Standard K8s RBAC: Role, ClusterRole, RoleBinding, ClusterRoleBinding
# OpenShift adds: oc adm policy commands as shortcuts
```

### ServiceAccount Pattern (Least Privilege)

```yaml
# 1. Create ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: my-project
automountServiceAccountToken: false   # Disable unless app calls K8s API
```

```yaml
# 2. Create Role (namespace-scoped)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
  namespace: my-project
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["my-app-secrets"]   # Restrict to specific secret
    verbs: ["get"]
```

```yaml
# 3. RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-app-rolebinding
  namespace: my-project
subjects:
  - kind: ServiceAccount
    name: my-app-sa
    namespace: my-project
roleRef:
  kind: Role
  apiGroup: rbac.authorization.k8s.io
  name: my-app-role
```

### RBAC + SCC Commands

```bash
# Assign SCC to ServiceAccount
oc adm policy add-scc-to-user anyuid -z my-app-sa -n my-project

# Assign Role to ServiceAccount
oc adm policy add-role-to-user view -z my-app-sa -n my-project

# Assign Role to human user
oc adm policy add-role-to-user edit username -n my-project

# Check what SCCs a SA has
oc get rolebindings,clusterrolebindings -A | grep my-app-sa

# Check if a user can perform an action
oc auth can-i get pods --as=system:serviceaccount:my-project:my-app-sa

# List all SCCs
oc get scc

# Describe an SCC to understand its rules
oc describe scc restricted-v2
oc describe scc anyuid
```

### OpenShift Built-in Roles

| Role | What It Allows |
|---|---|
| `view` | Read-only access to project resources |
| `edit` | Create, modify, delete most resources (not RBAC) |
| `admin` | Full project admin including RBAC |
| `cluster-admin` | God mode — cluster-wide everything |
| `registry-viewer` | Pull images from registry |
| `registry-editor` | Push + pull images to/from registry |
| `system:image-puller` | Pull images from a specific namespace |

---

## ConfigMaps and Secrets

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
data:
  LOG_LEVEL: "info"
  APP_ENV: "production"
  # Mount as file for complex config
  app.yaml: |
    server:
      port: 8080
      timeout: 30s
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
type: Opaque
stringData:                         # Plain text → auto base64 encoded
  db-password: mysecretpassword
  api-key: abc123xyz
# OR use data: with base64 values manually
# data:
#   db-password: bXlzZWNyZXRwYXNzd29yZA==
```

### Injection Methods — env vs envFrom

```yaml
# env + valueFrom — EXPLICIT (preferred in production)
# Created by: oc set env deployment/my-app --from=secret/my-app-secrets
env:
  - name: DB_PASSWORD               # Can RENAME the key
    valueFrom:
      secretKeyRef:
        name: my-app-secrets
        key: db-password            # Specific key only
  - name: LOG_LEVEL
    valueFrom:
      configMapKeyRef:
        name: my-app-config
        key: LOG_LEVEL
```

```yaml
# envFrom — BULK import (use with caution)
# Must be added manually via oc edit — NOT created by oc set env --from
envFrom:
  - configMapRef:
      name: my-app-config           # Imports ALL keys, original names
  - secretRef:
      name: my-app-secrets          # Imports ALL keys, cannot rename
```

### env vs envFrom Decision

| Need | Use |
|---|---|
| Select specific keys | `env` + `valueFrom` |
| Rename a key inside the pod | `env` + `valueFrom` |
| Avoid silent key conflicts | `env` + `valueFrom` |
| Import entire config file as-is | `envFrom` (with caution) |
| Visible in `oc set env --list` | `env` only — `envFrom` invisible |

### Mount as File (for complex config)

```yaml
volumes:
  - name: config-volume
    configMap:
      name: my-app-config
      items:
        - key: app.yaml
          path: app.yaml            # File name inside the mount path
volumeMounts:
  - name: config-volume
    mountPath: /etc/app
    readOnly: true
```

### Critical Secrets Insights

```bash
# base64 is NOT encryption — anyone can decode
oc get secret my-app-secrets -o jsonpath='{.data.db-password}' | base64 -d

# oc describe hides values (UX only — not security)
oc describe secret my-app-secrets    # Shows: db-password: 12 bytes

# Deployment stores REFERENCE not value — verify:
oc get deployment my-app -o yaml | grep -A5 valueFrom

# Secret deleted + running pod = pod continues (value injected at startup)
# Secret deleted + pod restart = CreateContainerConfigError

# For GitOps-safe secrets: use Sealed Secrets or External Secrets Operator
```

---

## Resource Management

```yaml
resources:
  requests:           # Scheduler uses this to place pod on node
    cpu: "100m"       # 100 millicores = 0.1 CPU core
    memory: "128Mi"
  limits:             # Container throttled (CPU) or killed (memory) above this
    cpu: "500m"
    memory: "256Mi"
```

### Rules of Thumb by Workload

| Workload | CPU Request | Memory Request | Notes |
|---|---|---|---|
| Node.js web API | 100–250m | 128–256Mi | Limits 2-4× requests |
| Java/JVM app | 500m–1 | 512Mi–2Gi | Allow headroom above -Xmx |
| Python worker | 250–500m | 256–512Mi | Memory limit = request |
| PostgreSQL | 250–500m | 256Mi–1Gi | Depends on dataset size |
| Sidecar/init | 10–50m | 32–64Mi | Keep minimal |

### LimitRange (Project-level defaults)

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: my-project
spec:
  limits:
    - type: Container
      default:                    # Applied if no limits set
        cpu: "500m"
        memory: "256Mi"
      defaultRequest:             # Applied if no requests set
        cpu: "100m"
        memory: "128Mi"
      max:                        # Hard ceiling per container
        cpu: "2"
        memory: "1Gi"
```

### ResourceQuota (Project-level ceiling)

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project-quota
  namespace: my-project
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
    pods: "20"
    persistentvolumeclaims: "5"
```

---

## Tekton Pipelines

### Core Resources

```yaml
# Task — a set of steps that run sequentially in one pod
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-and-test
spec:
  params:
    - name: IMAGE
      type: string
  workspaces:
    - name: source
  steps:
    - name: test
      image: registry.access.redhat.com/ubi8/nodejs-18
      workingDir: $(workspaces.source.path)
      script: |
        npm install
        npm test
    - name: build
      image: registry.access.redhat.com/ubi8/buildah
      script: |
        buildah bud -t $(params.IMAGE) .
        buildah push $(params.IMAGE)
```

```yaml
# Pipeline — orchestrates Tasks
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-deploy-pipeline
spec:
  params:
    - name: GIT_URL
    - name: IMAGE
  workspaces:
    - name: shared-workspace
  tasks:
    - name: clone
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.GIT_URL)
    - name: build
      runAfter: [clone]           # Ordering
      taskRef:
        name: build-and-test
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: $(params.IMAGE)
```

```yaml
# PipelineRun — one execution of a Pipeline
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: build-deploy-run-1
spec:
  pipelineRef:
    name: build-deploy-pipeline
  params:
    - name: GIT_URL
      value: https://github.com/org/repo.git
    - name: IMAGE
      value: image-registry.openshift-image-registry.svc:5000/my-project/my-app:latest
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes: [ReadWriteOnce]
          resources:
            requests:
              storage: 1Gi
```

### Tekton Commands

```bash
# List pipeline runs
oc get pipelineruns
tkn pipelinerun list

# Follow pipeline run logs
tkn pipelinerun logs <run-name> -f

# List task runs
oc get taskruns
tkn taskrun list

# Trigger a new pipeline run
tkn pipeline start build-deploy-pipeline \
  -p GIT_URL=https://github.com/org/repo.git \
  -p IMAGE=image-registry.openshift-image-registry.svc:5000/my-project/my-app:latest \
  -w name=shared-workspace,claimName=my-pvc \
  --showlog
```

---

## Autoscaling

### HPA

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
  namespace: my-project
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

```bash
# HPA requires resource requests to be set
# Check HPA status
oc get hpa
oc describe hpa my-app-hpa
```

### PodDisruptionBudget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
  namespace: my-project
spec:
  minAvailable: 2       # OR: maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

---

## oc Debugging Cheatsheet

```bash
# ─── Pod status ───
oc get pods -n my-project
oc get pods -n my-project -o wide          # Show node assignment
oc get pods -A                             # All namespaces
oc get pods -w                             # Watch live

# ─── Describe and logs ───
oc describe pod <pod-name>                 # Events, state, SCC, conditions
oc logs <pod-name>                         # Current logs
oc logs <pod-name> --previous             # Logs from crashed container
oc logs <pod-name> -c <container>         # Multi-container pod
oc logs -f deployment/my-app              # Follow deployment logs

# ─── Shell into pod ───
oc rsh <pod-name>                          # Remote shell (OpenShift shortcut)
oc exec -it <pod-name> -- /bin/sh         # Standard exec

# ─── Copy files ───
oc cp <pod-name>:/path/to/file ./local    # Pod → local
oc cp ./local <pod-name>:/path/to/file   # local → pod

# ─── Resource usage ───
oc adm top pods -n my-project
oc adm top nodes

# ─── Events (most useful for diagnosing failures) ───
oc get events -n my-project --sort-by=.lastTimestamp
oc get events -n my-project | grep Warning

# ─── Port forward for local debugging ───
oc port-forward pod/<pod-name> 8080:8080
oc port-forward svc/my-app 8080:8080

# ─── Deployment operations ───
oc rollout status deployment/my-app
oc rollout history deployment/my-app
oc rollout undo deployment/my-app          # Rollback
oc rollout restart deployment/my-app       # Force restart all pods

# ─── Scale ───
oc scale deployment my-app --replicas=3
oc autoscale deployment my-app --min=2 --max=10 --cpu-percent=70

# ─── Dry run ───
oc apply -f deployment.yaml --dry-run=client
oc apply -f deployment.yaml --dry-run=server

# ─── Get resource as YAML ───
oc get deployment my-app -o yaml
oc get pod <pod-name> -o yaml | grep -i scc
oc get pod <pod-name> -o jsonpath='{.spec.containers[0].image}'

# ─── Explain any resource field ───
oc explain pod.spec.securityContext
oc explain deployment.spec.strategy
oc explain route.spec.tls

# ─── Build debugging ───
oc get builds
oc logs build/my-app-1
oc describe build my-app-1
oc cancel-build my-app-1

# ─── Cluster diagnostics ───
oc get clusteroperators
oc adm must-gather                         # Collect full diagnostics
```

### Common Error Diagnosis

```bash
# CrashLoopBackOff
oc logs <pod> --previous                   # What crashed?
oc describe pod <pod> | grep "Exit Code"   # Exit code tells you why
# Exit 1   = app error
# Exit 137 = OOMKilled (increase memory limit)
# Exit 126/127 = command not found
# Exit 1 + "Permission denied" = likely SCC issue

# ImagePullBackOff
oc describe pod <pod> | grep -A10 Events   # Check pull error message
# Causes: wrong image name/tag, missing pull secret, registry auth, proxy issue

# SCC violation
oc get events | grep "forbidden"
oc describe pod <pod> | grep "unable to validate"
# Fix: oc adm policy add-scc-to-user <scc> -z <sa> -n <ns>

# Service not routing traffic
oc get endpoints <svc-name>               # Empty = no pods match selector
oc get pod --show-labels                  # Check labels match service selector
oc describe svc <name> | grep Selector    # Check selector

# Build fails — auth error
oc adm policy add-scc-to-user registry-viewer \
  system:serviceaccount:<ns>:default -n openshift
```

---

## Anti-Patterns

```yaml
# BAD: Using privileged SCC for app workloads
oc adm policy add-scc-to-user privileged -z my-app-sa
# GOOD: Use minimum required SCC (anyuid, nonroot, etc.)

# BAD: Using :latest image tag
image: nginx:latest
# GOOD: Pin to digest or specific version
image: image-registry.openshift-image-registry.svc:5000/my-project/my-app@sha256:abc123

# BAD: Running as root when not needed
securityContext:
  runAsUser: 0
# GOOD: Let OpenShift assign a random UID (restricted-v2 does this automatically)

# BAD: Using default ServiceAccount for app pods
# Pods use default SA automatically — it has no special permissions but shares token
# GOOD: Always create a dedicated SA per app
oc create sa my-app-sa

# BAD: Storing plaintext secrets in ConfigMaps
data:
  DB_PASSWORD: "mysecretpassword"   # NEVER
# GOOD: Use Secret resource, and for GitOps use Sealed Secrets

# BAD: base64 thinking you encrypted something
data:
  password: bXlzZWNyZXQ=   # This is NOT encrypted — anyone can decode it
# GOOD: Understand base64 = encoding not encryption. Use RBAC + etcd encryption

# BAD: envFrom for secrets with many keys
envFrom:
  - secretRef:
      name: massive-secret   # Imports ALL 50 keys — app only needs 2
# GOOD: env + valueFrom for specific keys only

# BAD: No resource limits
containers:
  - name: app
    image: my-app:latest
    # No resources: {} — one pod can starve the node
# GOOD: Always set requests AND limits

# BAD: Re-applying template with generate: expression
oc process -f template.yaml | oc apply -f -   # Generates new password every time
# GOOD: Pass password explicitly on re-apply
oc process -f template.yaml -p DB_PASSWORD=fixedvalue | oc apply -f -

# BAD: ImageChange trigger + GitOps tool managing same Deployment
# ArgoCD and the trigger fight over Deployment image field → perpetual OutOfSync
# GOOD: Remove triggers when using GitOps
oc set triggers deployment/my-app --remove-all
```

---

## Best Practices Checklist

### Security
- [ ] Pod runs as non-root (restricted-v2 SCC enforces this by default)
- [ ] Dedicated ServiceAccount per app (never use `default` SA)
- [ ] Minimum required SCC assigned — never `privileged`
- [ ] `allowPrivilegeEscalation: false`
- [ ] `readOnlyRootFilesystem: true` with `emptyDir` for writable paths
- [ ] All capabilities dropped (`capabilities.drop: [ALL]`)
- [ ] `automountServiceAccountToken: false` unless app calls K8s API
- [ ] RBAC follows least privilege (Role not ClusterRole unless needed)
- [ ] Secrets managed via Sealed Secrets or External Secrets for GitOps
- [ ] No plaintext secrets in ConfigMaps or Deployment YAML

### Reliability
- [ ] All 3 probe types configured (startup + liveness + readiness)
- [ ] Resource requests AND limits set on every container
- [ ] `minReplicas: 2+` for production workloads
- [ ] PodDisruptionBudget defined for critical services
- [ ] `RollingUpdate` strategy with `maxUnavailable: 0`
- [ ] HPA configured for variable-load services
- [ ] ImageStream trigger removed if GitOps tool manages deployments

### Builds
- [ ] BuildConfig uses specific builder image tag (not `latest`)
- [ ] Build hook (postCommit) runs tests before image push
- [ ] ImageStream used as build output target
- [ ] Binary build strategy for pre-built artifacts

### Observability
- [ ] App exposes `/health` (liveness) and `/ready` (readiness) endpoints
- [ ] Structured JSON logging
- [ ] Resource labels: `app`, `version`, `environment`
- [ ] Events checked after every deployment (`oc get events --sort-by=.lastTimestamp`)

---

## Related Skills

- `kubernetes-patterns` — Vanilla K8s patterns (base layer OpenShift builds on)
- `gitops-patterns` — ArgoCD + ApplicationSets + Sealed Secrets
- `tekton-patterns` — Deep Tekton pipeline patterns
- `openshift-admin-patterns` — EX280 admin topics (etcd, nodes, cluster operators)