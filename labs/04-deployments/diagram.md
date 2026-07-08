# Diagram 04: Deployment Rolling Update and Rollback

```mermaid
flowchart LR
  subgraph User[User Actions]
    U[oc apply / oc set image / oc rollout undo]
  end

  subgraph CP[Control Plane]
    API[API Server]
    ETCD[(etcd)]
    DC[Deployment Controller]
    RSC[ReplicaSet Controller]
    SCH[Scheduler]
  end

  subgraph K8s[Kubernetes Runtime]
    DEP[Deployment]
    RSOLD[Old ReplicaSet]
    RSNEW[New ReplicaSet]
    POD[Pods]
    KLET[Kubelet]
    SVC[Service]
  end

  subgraph OCP[OpenShift Layer]
    BC[BuildConfig]
    IS[ImageStream]
    RT[Route]
  end

  U --> API
  API --> ETCD
  API --> DEP
  API --> DC
  DC --> RSOLD
  DC --> RSNEW
  RSC --> POD
  POD --> SCH
  SCH --> POD
  POD --> KLET
  KLET --> API

  BC --> IS
  IS -. image reference .-> DEP
  RT --> SVC
  SVC --> POD
```

Arrow meanings:

- `User -> API Server`: rollout intent is submitted.
- `API Server -> etcd`: deployment and revision state is persisted.
- `API Server -> Deployment`: desired deployment spec is stored and served.
- `API Server -> Deployment Controller`: controller receives updated desired state via watches.
- `Deployment Controller -> Old/New ReplicaSet`: controller scales old and new revisions per strategy.
- `ReplicaSet Controller -> Pods`: each ReplicaSet reconciles its Pod count.
- `Pods -> Scheduler`: unscheduled Pods enter scheduling queue.
- `Scheduler -> Pods`: node binding assignment is written.
- `Pods -> Kubelet`: node agent starts and monitors containers.
- `Kubelet -> API Server`: runtime status and events are reported.
- `BuildConfig -> ImageStream`: build outputs tracked in OpenShift.
- `ImageStream -> Deployment`: deployment image may be sourced from tracked image tags.
- `Route -> Service -> Pods`: external request path to active application pods.

Troubleshooting focus:

- If rollout stalls, inspect Deployment conditions, ReplicaSet counts, and Pod events.
- If bad image breaks rollout, identify failing revision and rollback.
- If resources appear absent, validate project context and query all namespaces.
