# 🚀 OpenShift EX288 Training Roadmap

> **Daily Challenge System — CRC Local Environment**
> Coach: Claude | Student: Amine | Started: June 2026
> Style: 80% hands-on · 20% theory · Strict evaluation · Deep understanding

---

<!-- - to generate later
- [x] 02 oc CLI vs kubectl — syntax differences, `oc explain`, output formats
- [x] 03 Services + Routes — ClusterIP, HAProxy, edge/passthrough/reencrypt
- [x] 04 Service Discovery — endpoints controller, DNS, selector matching -->

## 🟢 Phase 1 — OpenShift Foundations

> Learn what makes OpenShift different from vanilla K8s.

- [x] 01 Projects + Namespaces — `oc new-project`, context switching
- [x] 02 pods
- [x] 03 replicasets
- [x] 04 deployments
- [x] 05 Security Context Constraints (SCC)

---

## 🟢 Phase 2 — Building Apps

> The heart of EX288. S2I + ImageStreams + Builds.

- [x] 06 ImageStreams — tags vs digests, trigger chain, SHA256 in Deployment
- [x] 07 BuildConfigs + S2I — BuildConfig vs Build, assemble script, builder images
- [x] 08 Binary Builds — build locally, push artifact
- [x] 09 Build Triggers + Build Hooks
- [x] 10 Build Troubleshooting — logs, common failures, auth errors ✅ _Mission generated (labs/10-build-troubleshooting)_

---

## 🟢 Phase 3 — App Configuration

> Keep config out of the image. Single source of truth.

- [x] 11 ConfigMaps — from-literal, from-file, mount as volume or env
- [x] 12 Secrets — Opaque, base64 != encryption, RBAC as real protection
- [x] 13 env vs envFrom — valueFrom, secretKeyRef, silent conflicts
- [x] 14 Volumes + PVCs — emptyDir vs PVC, RWO vs RWX
- [x] 15 Storage Patterns — ephemeral vs persistent, StatefulSets

---

## 🔵 Phase 4 — App Health & Resources

- [x] 16 Health Checks — Liveness + Readiness + Startup probes
- [x] 17 Resource Requests + Limits — CPU/memory, OOMKilled, throttling
- [ ] 18 Quotas + LimitRanges — project-level enforcement

---

## Phase 5 — Packaging & Deployment

- [x] 19 Templates — objects, apiVersion, generate expression
- [x] 20 Template Parameters — required, defaults, ${{numeric}}, re-apply problem _(Score: 8/10)_
- [ ] 21 Helm on OpenShift — you know Helm, focus on OpenShift specifics
- [ ] 22 Helm Troubleshooting — history, rollback, failed releases
- [ ] 23 Kustomize on OpenShift — base + overlays, namePrefix, patches
- [ ] 24 Kustomize Environment Customization — dev/staging/prod overlays
- [ ] 25 Rolling Updates + Rollbacks — maxSurge, maxUnavailable, oc rollout
- [ ] 26 Deployment Strategies — Recreate, RollingUpdate, Blue-Green, Canary

---

## Phase 6 — CI/CD with Tekton

> You know Tekton. Focus on OpenShift Pipelines operator + EX288 objectives.

- [ ] 27 Tekton Architecture — Task, Pipeline, PipelineRun, how they connect
- [ ] 28 Tasks + Steps — params, results, workspaces
- [ ] 29 Pipelines + PipelineRuns — ordering, parallel, finally tasks
- [ ] 30 Workspaces — PVC, emptyDir, Secret, ConfigMap workspace types
- [ ] 31 Triggers + Git Integration — EventListener, TriggerTemplate, TriggerBinding
- [ ] 32 Tekton Troubleshooting — failed TaskRuns, workspace issues

---

## Phase 7 — Operators

> EX288 objective: create apps from installed Operators.

- [ ] 33 Operator Pattern — CRD + Controller + CR + reconciliation loop
- [ ] 34 OLM — install, update, delete operators
- [ ] 35 Creating Apps from Operators
- [ ] 36 Operator Troubleshooting — degraded operators, CR errors

---

## Phase 8 — Networking Deep

- [ ] 37 Services Deep Dive — kube-proxy, iptables, Endpoints controller internals
- [ ] 38 Routes Deep Dive — TLS certificates, route annotations, HAProxy tuning
- [ ] 39 DNS Resolution — CoreDNS, service DNS format, cross-namespace
- [ ] 40 Network Troubleshooting — tcpdump in pods, connectivity matrix

---

## Phase 9 — Storage Deep

- [ ] 41 Persistent Volumes — PV lifecycle, access modes, reclaim policies
- [ ] 42 Dynamic Provisioning — StorageClass, provisioner, binding modes
- [ ] 43 StatefulSets + Storage — volumeClaimTemplates, stable identity
- [ ] 44 Storage Troubleshooting — PVC stuck Pending, full volumes

---

## Phase 10 — Monitoring & Logging

- [ ] 45 Application + Build Logs — oc logs, --previous, multi-container
- [ ] 46 Event Analysis — oc get events, what each type means
- [ ] 47 Metrics + Monitoring Concepts — oc adm top, Prometheus basics

---

## Phase 11 — OpenShift Internals

- [ ] 48 API Server + etcd — every oc command is an API call
- [ ] 49 Controllers + Reconciliation Loop — how things stay in sync
- [ ] 50 OpenShift Authentication — OAuth, HTPasswd, token lifecycle
- [ ] 51 Internal Registry Configuration

---

## Phase 12 — Troubleshooting Mastery

> Exam simulation mode — diagnose and fix under time pressure.

- [ ] 52 CrashLoopBackOff — exit codes, reading logs, SCC issues
- [ ] 53 ImagePullBackOff — registry auth, wrong image, proxy issues
- [ ] 54 Failed Builds — S2I failures, missing builder, Git clone errors
- [ ] 55 Route + Service Issues — 503 vs 404 vs 403, selector mismatch
- [ ] 56 ConfigMap + Secret Issues — missing key, wrong name, encoding errors
- [ ] 57 PVC + Storage Issues — stuck Pending, wrong access mode
- [ ] 58 Scheduling + Resource Problems — OOMKilled, quota exceeded, evictions

---

## Phase 13 — Platform Engineering

> Beyond EX288. Cloud Architect path.

- [ ] 59 GitOps Concepts — Git as source of truth, drift detection
- [ ] 60 ArgoCD Fundamentals — Application, sync policies, health checks
- [ ] 61 Multi-Environment Promotion — dev→staging→prod, PR-based gates
- [ ] 62 Sealed Secrets + Vault — GitOps-safe secrets management
- [ ] 63 Platform Design — multi-tenancy, golden paths, IDP concepts

---

## 🎯 Capstone Projects

- [ ] P1 Stateless App — S2I + ImageStream + Route + ConfigMap + health checks + limits
- [ ] P2 Stateful App — PostgreSQL + PVC + StatefulSet + Secret + backup
- [ ] P3 CI/CD Pipeline — Git push → Tekton build → image push → GitOps deploy
- [ ] P4 Production Platform — multi-tenant + GitOps + monitoring + runbook

---

## 📅 Session Log

| Date                  | Challenge                            | Topic                               | Score | Doc                                  |
| --------------------- | ------------------------------------ | ----------------------------------- | ----- | ------------------------------------ |
| June 2026 (Days 1–3)  | Routes + Services lab                | Services, Routes, Endpoints         | 7/10  | —                                    |
| June 2026 (Day 7)     | S2I Build Investigation              | ImageStreams, BuildConfig, S2I      | 6/10  | ✅ imagestream_deep_dive.docx        |
| June 2026 (Days 8–13) | PostgreSQL + ConfigMap/Secret wiring | ConfigMaps, Secrets, env vs envFrom | 7/10  | ✅ configmaps_secrets_deep_dive.docx |
| June 24, 2026         | Custom Template build                | Templates, Parameters, generate     | 8/10  | —                                    |

---

## 🔴 Weak Areas — Must Revisit

- [ ] **SCC** — hit it on Day 1 (nginx crash) but never did a dedicated challenge
- [ ] **Build Hooks** — EX288 objective, not covered yet
- [ ] **Internal Registry config** — EX288 objective, not covered yet
- [ ] **Endpoints Controller** — you said "service updates endpoints" (wrong — it's the controller)
- [ ] **Operators** — creating apps from CRs not practiced yet

---

## ✅ Readiness Checkpoints

- [ ] **EX288 Ready** — Complete topics 1–10 + Capstone P1
- [ ] **EX280 Ready** — Complete all topics + Capstone P2
- [ ] **Platform Engineer** — Complete Capstone P3–P4

## 📋 EX288 Objective Coverage

| EX288 Objective                        | Our Topic | Status        |
| -------------------------------------- | --------- | ------------- |
| Work with multiple projects            | 01        | ✅ Done       |
| Deploy single + multi-container apps   | 07, 19    | ✅ Done       |
| Use application health monitoring      | 16–18     | ⬅️ Next       |
| Git usage in OpenShift context         | 07, 09    | 🔄 Partial    |
| Configure internal registry            | 51        | ⬜ Pending    |
| Manage apps with web console           | 02        | 🔄 Partial    |
| Create and use Helm charts             | 21–22     | ⬜ Pending    |
| Customize with Kustomize               | 23–24     | ⬜ Pending    |
| Work with image builds + BuildConfigs  | 07–10     | 🔄 Partial    |
| Custom S2I builder workflows           | 07        | 🔄 Partial    |
| Publish images to internal registry    | 51        | ⬜ Pending    |
| Troubleshoot builds + deployments      | 52–58     | ⬜ Pending    |
| ImageStreams — custom, triggers, debug | 06        | ✅ Done       |
| ConfigMaps — create + inject           | 11–13     | ✅ Done       |
| Secrets — create + inject              | 11–13     | ✅ Done       |
| S2I — build + customize                | 07        | 🔄 Partial    |
| Build hooks + triggers                 | 09        | ⬜ Pending ⚠️ |
| Templates — create + parameters        | 19–20     | ✅ Done       |
| OpenShift Pipelines (Tekton)           | 27–32     | ⬜ Pending    |
| Operators — create apps from operators | 35        | ⬜ Pending ⚠️ |

---

> _"Don't count the days. Make the days count."_
> Next: **Topic 18 — Quotas + LimitRanges** → say `Next Challenge`
