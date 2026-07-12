# Diagram 02: Pod Lifecycle and Control Plane Flow

```mermaid
flowchart LR
  subgraph UserLayer[User Actions]
    U[oc run / oc apply]
  end

  subgraph ControlPlane[Control Plane]
    API[API Server]
    ETCD[(etcd)]
    SCH[Scheduler]
    CTRL[Controllers]
  end

  subgraph KubernetesLayer[Kubernetes Runtime Layer]
    POD[Pod]
    KLET[Kubelet]
  end

  subgraph OpenShiftLayer[OpenShift Layer]
    BC[BuildConfig]
    IS[ImageStream]
    RT[Route]
  end

  U --> API
  API --> ETCD
  API --> SCH
  SCH --> POD
  POD --> KLET
  KLET --> API
  CTRL --> API
  API --> CTRL

  BC --> IS
  IS -. image reference .-> POD
  RT -. traffic path via Service .-> POD
```

Arrow meanings:

- `User -> API Server`: user submits desired state changes.
- `API Server -> etcd`: cluster state is persisted.
- `API Server -> Scheduler`: unscheduled Pods are evaluated for placement.
- `Scheduler -> Pod`: node binding decision is written.
- `Pod -> Kubelet`: node agent receives desired Pod workload.
- `Kubelet -> API Server`: status and events are reported back.
- `Controllers <-> API Server`: controllers watch objects and reconcile drift.
- `BuildConfig -> ImageStream`: OpenShift build output is tracked by tag.
- `ImageStream -> Pod`: runtime can consume tracked image versions.
- `Route -> Pod`: external traffic reaches workloads through routing and service mapping.

Troubleshooting focus:

- If Pod is not running, inspect API object status, events, and kubelet-related messages.
- If image pull fails, validate image source/tag and compare with ImageStream or registry reference.
- If Pod is missing, verify project context and query across namespaces.
