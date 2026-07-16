# Diagram 16: Probe Flow and Traffic Gating

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
    EPCTRL[Endpoints Controller]
    SCHED[Scheduler]
  end

  subgraph NodeLayer[Node and Workload]
    DEP[Deployment probe-demo]
    RS[ReplicaSet]
    POD[Pod]
    KUBELET[Kubelet Probe Loop]
    SVC[Service probe-demo]
    EPS[Endpoints EndpointSlice]
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
  KUBELET -->|startup/readiness/liveness result| POD

  POD --> API
  API --> EPCTRL
  EPCTRL --> EPS
  SVC --> EPS
  RT --> SVC
```

Arrow meanings:

- `BuildConfig -> ImageStream`: build output updates image tracking.
- `ImageStream -> Deployment`: deployment consumes image revisions.
- `Deployment -> API Server`: desired probe specs are submitted.
- `API Server -> etcd`: desired and observed state is persisted.
- `API Server -> Deployment/ReplicaSet controllers`: pod reconciliation begins.
- `Scheduler -> Pod`: pod is assigned to a node.
- `Pod -> Kubelet`: kubelet runs container and executes probes.
- `Kubelet -> Pod`: probe results update readiness and restart behavior.
- `Pod/API/Endpoints controller`: readiness state drives endpoint membership.
- `Route -> Service -> Endpoints`: external traffic reaches only Ready pods.

## Failure and Recovery Sequence

```mermaid
sequenceDiagram
  participant U as User
  participant API as API Server
  participant ETCD as etcd
  participant D as Deployment Controller
  participant R as ReplicaSet Controller
  participant K as Kubelet
  participant E as Endpoints Controller

  U->>API: Patch readiness path to wrong endpoint
  API->>ETCD: Store new pod template
  D->>R: Create new ReplicaSet revision
  R->>API: Create replacement Pod
  K->>API: Readiness probe fails repeatedly
  E->>API: Remove pod from Service endpoints

  U->>API: Patch readiness path back to valid endpoint
  API->>ETCD: Store corrected template
  D->>R: Reconcile rollout
  K->>API: Probe succeeds, pod Ready
  E->>API: Add pod back to endpoints
```

Arrow meanings:

- `User -> API Server`: each oc patch changes desired state.
- `API Server -> etcd`: every revision is persisted.
- `Deployment/ReplicaSet controllers`: rollout and pod replacement happen by reconciliation.
- `Kubelet -> API Server`: probe outcomes update pod conditions and events.
- `Endpoints controller`: service traffic eligibility follows readiness state.