generate me this whole folder structure for a project called `openshift-platform-playground` with the following subfolders : (all are empty folders)

openshift-platform-playground/

├── frontend/          # React application
├── backend/           # NestJS API
├── database/          # DB init scripts, schema, seed data
│
├── manifests/         # Raw Kubernetes/OpenShift YAML
│   ├── base/
│   ├── dev/
│   └── prod/
│
├── helm/              # Helm chart(s)
│
├── kustomize/         # Kustomize bases & overlays
│
├── tekton/            # Tasks, Pipelines, Triggers
│
├── gitops/            # Argo CD Applications & GitOps manifests
│
├── monitoring/        # Prometheus, Grafana, ServiceMonitor
│
├── logging/           # ClusterLogForwarder, Loki/EFK configs
│
├── security/          # RBAC, ServiceAccounts, NetworkPolicies, SCC
│
├── storage/           # PV, PVC, StorageClass examples
│
├── scripts/           # Helper scripts (build, deploy, cleanup)
│
├── docs/              # Architecture, diagrams, notes
│
├── labs/              # Your learning missions
│
├── submission-history/# Reviews and scores
│
└── README.md          # Project overview & setup