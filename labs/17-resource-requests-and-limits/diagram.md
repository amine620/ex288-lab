# Diagram 17: Resource Requests and Limits Flow

```mermaid
flowchart LR
  subgraph OpenShiftLayer[OpenShift Layer]
    BC[BuildConfig]
    IS[ImageStream]
    RT[Route]
  end

  subgraph ControlPlane[Kubernetes Control Plane]
    API[API Server]
    ETCD[(etcd)]
    DCTRL[Deployment Controller]
    RSCTRL[ReplicaSet Controller]
    SCHED[Scheduler]
  end

  subgraph NodeLayer[Node Runtime]
    DEP[Deployment]
    RS[ReplicaSet]
    POD[Pod]
    KUBELET[Kubelet]
    CGRP[cgroups CPU and Memory]
    SVC[Service]
  end

  BC --> IS
  IS --> DEP
  DEP --> API
  API --> ETCD
  API --> DCTRL
  DCTRL --> RS
  RSCTRL --> POD
  SCHED --> POD
  POD --> KUBELET
  KUBELET --> CGRP
  SVC --> POD
  RT --> SVC
```

Arrow meanings:

- BuildConfig to ImageStream: build output versions are tracked.
- ImageStream to Deployment: deployment consumes image revisions.
- Deployment to API Server: desired resource requests and limits are submitted.
- API Server to etcd: desired and observed state is persisted.
- Deployment controller to ReplicaSet: rollout revision management.
- ReplicaSet controller to Pod: desired replica count is enforced.
- Scheduler to Pod: placement decision uses requests versus node allocatable resources.
- Pod to kubelet: node agent receives pod spec and lifecycle responsibility.
- Kubelet to cgroups: runtime CPU and memory limits are enforced.
- Service and Route path: traffic reaches pods that are running and ready.

## Failure and Recovery Sequence

```mermaid
sequenceDiagram
  participant U as User
  participant API as API Server
  participant ETCD as etcd
  participant D as Deployment Controller
  participant R as ReplicaSet Controller
  participant S as Scheduler
  participant K as Kubelet

  U->>API: Patch deployment with low memory limit
  API->>ETCD: Persist new template
  D->>R: Create new ReplicaSet revision
  R->>API: Create Pod
  S->>API: Bind Pod to node
  K->>API: Container OOMKilled event and restart updates

  U->>API: Patch deployment with oversized request
  API->>ETCD: Persist revised template
  D->>R: Create replacement Pod
  S->>API: FailedScheduling event insufficient resources

  U->>API: Patch balanced requests and limits
  API->>ETCD: Persist stable values
  D->>R: Reconcile rollout
  S->>API: Pod scheduled
  K->>API: Pod running and stable
```

Arrow meanings:

- User to API Server: each CLI action updates desired state.
- API Server to etcd: every spec/status transition is recorded.
- Deployment and ReplicaSet controllers: new revisions and pod replacement happen by reconciliation.
- Scheduler: admits or rejects pod placement based on requests.
- Kubelet: enforces runtime limits and reports OOM/restart outcomes.
- Final patch: corrected values allow stable convergence to desired state.