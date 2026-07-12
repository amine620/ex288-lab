# Diagram 15: Storage Patterns and Controllers

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
    SSCTRL[StatefulSet Controller]
    RSCTRL[ReplicaSet Controller]
    PVCCTRL[PVC PV Controller]
    SCHED[Scheduler]
  end

  subgraph Workloads[Kubernetes Workload Layer]
    DEP[Deployment cache-api]
    RS[ReplicaSet]
    PODA[Pod cache-api]
    STS[StatefulSet orders-db]
    PODB[Pod orders-db-0]
    SVC1[Service orders-headless]
    SVC2[Service app-service]
    PVC[PVC data-orders-db-0]
    PV[PersistentVolume]
    ED[emptyDir cache]
    KUBELET[Kubelet]
  end

  BC --> IS
  IS --> DEP
  IS --> STS

  DEP --> API
  STS --> API
  API --> ETCD

  API --> DCTRL
  API --> SSCTRL
  API --> PVCCTRL

  DCTRL --> RS
  RSCTRL --> PODA
  SSCTRL --> PODB
  SSCTRL --> PVC
  PVCCTRL --> PVC
  PVCCTRL --> PV

  SCHED --> PODA
  SCHED --> PODB
  PODA --> KUBELET
  PODB --> KUBELET
  KUBELET --> ED
  KUBELET --> PVC
  PVC --> PV

  SVC1 --> PODB
  SVC2 --> PODA
  RT --> SVC2
```

Arrow meanings:

- `BuildConfig -> ImageStream`: Build pipeline publishes image versions.
- `ImageStream -> Deployment/StatefulSet`: Workloads consume tracked image tags.
- `Deployment/StatefulSet -> API Server`: Desired state is submitted.
- `API Server -> etcd`: State is persisted as control-plane source of truth.
- `API Server -> controllers`: Reconciliation loops are triggered by watch events.
- `Deployment Controller -> ReplicaSet -> Pod`: Stateless pod lifecycle management.
- `StatefulSet Controller -> Pod/PVC`: Stable identity and claim orchestration.
- `PVC/PV Controller -> PVC/PV`: Provisioning and binding operations.
- `Scheduler -> Pods`: Node placement decisions.
- `Kubelet -> emptyDir/PVC`: Node-side mount and runtime enforcement.
- `Service/Route chain`: Networking exposure independent from storage durability.

## Failure and Recovery Sequence

```mermaid
sequenceDiagram
  participant U as User
  participant API as API Server
  participant ETCD as etcd
  participant SS as StatefulSet Controller
  participant PVC as PVC PV Controller
  participant SCH as Scheduler
  participant K as Kubelet

  U->>API: Apply StatefulSet with invalid StorageClass
  API->>ETCD: Persist desired state
  SS->>API: Create Pod and PVC objects
  PVC->>API: Update PVC Pending status
  SCH->>API: Attempt scheduling
  K->>API: Report mount/provision dependency events
  U->>API: Patch StatefulSet claim template and recreate claim
  PVC->>API: Bind PVC to PV
  K->>API: Mount succeeds
  SS->>API: Pod reaches Ready, state reconciled
```

Arrow meanings:

- `User -> API Server`: Each CLI action submits a desired-state change.
- `API Server -> etcd`: Persisted definitions drive all reconciliation.
- `StatefulSet Controller -> API Server`: Pod/PVC generation for ordinal identity.
- `PVC/PV Controller -> API Server`: Claim lifecycle updates and binding status.
- `Scheduler/Kubelet -> API Server`: Placement plus node execution feedback.
- `Patch/fix path`: Controllers converge actual state back to desired state.