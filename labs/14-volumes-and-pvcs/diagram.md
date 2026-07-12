# Diagram 14: Volumes and PVC Lifecycle

```mermaid
flowchart LR
  subgraph OpenShiftLayer[OpenShift Layer]
    BC[BuildConfig]
    IS[ImageStream]
    RT[Route]
  end

  subgraph K8sControlPlane[Kubernetes Control Plane]
    API[API Server]
    ETCD[(etcd)]
    PVCCTRL[PVC PV Controller]
    DCTRL[Deployment Controller]
    RSCTRL[ReplicaSet Controller]
    SCHED[Scheduler]
  end

  subgraph Workload[Kubernetes Workload Layer]
    DEP[Deployment]
    RS[ReplicaSet]
    POD[Pod]
    SVC[Service]
    PVC[PersistentVolumeClaim]
    PV[PersistentVolume]
    ED[emptyDir]
    KUBELET[Kubelet]
  end

  BC --> IS
  IS --> DEP
  DEP --> RS
  RS --> POD
  SVC --> POD
  RT --> SVC

  DEP --> API
  PVC --> API
  API --> ETCD

  API --> DCTRL
  API --> PVCCTRL
  DCTRL --> RS
  RSCTRL --> POD
  PVCCTRL --> PVC
  PVCCTRL --> PV

  SCHED --> POD
  POD --> KUBELET
  KUBELET --> ED
  KUBELET --> PVC
  PVC --> PV
```

Arrow meanings:

- `BuildConfig -> ImageStream`: Build process publishes app image tags.
- `ImageStream -> Deployment`: Deployment can consume tracked image versions.
- `Deployment -> ReplicaSet -> Pod`: Controllers create and maintain running Pods.
- `Service -> Pod`: Service selects Pods for stable internal networking.
- `Route -> Service`: Route exposes the Service externally.
- `Deployment/PVC -> API Server`: Desired state is submitted to the control plane.
- `API Server -> etcd`: Desired and observed state is persisted.
- `API Server -> Controllers`: Controllers watch resources and reconcile.
- `PVC PV Controller -> PVC/PV`: Claim binding and dynamic provisioning logic.
- `Scheduler -> Pod`: Pod gets node assignment.
- `Pod -> Kubelet`: Node agent receives pod spec and enforces it.
- `Kubelet -> emptyDir/PVC`: Volumes are mounted before container start.
- `PVC -> PV`: Claim is satisfied by a concrete volume.

## Failure and Recovery Sequence

```mermaid
sequenceDiagram
  participant User
  participant API as API Server
  participant ETCD as etcd
  participant PVCCTRL as PVC/PV Controller
  participant DCTRL as Deployment Controller
  participant SCHED as Scheduler
  participant KUBELET as Kubelet

  User->>API: Create PVC with bad StorageClass
  API->>ETCD: Store PVC spec
  PVCCTRL->>API: Update PVC status Pending
  User->>API: Create Deployment using that claim
  DCTRL->>API: Create Pod
  SCHED->>API: Bind Pod to node
  KUBELET->>API: Report mount failure events
  User->>API: Fix PVC or Deployment claim reference
  PVCCTRL->>API: Bind PVC to PV
  KUBELET->>API: Mount succeeds, Pod becomes Ready
```

Arrow meanings:

- `User -> API Server`: Each oc command submits an API request.
- `API Server -> etcd`: Resource specs are persisted as source of truth.
- `PVC/PV Controller -> API Server`: Claim status transitions (Pending/Bound).
- `Deployment Controller -> API Server`: Pod creation for desired replicas.
- `Scheduler -> API Server`: Node binding decision is recorded.
- `Kubelet -> API Server`: Mount errors/success and pod condition updates.
- `User fix -> controllers`: Reconciliation loops apply corrected state until ready.