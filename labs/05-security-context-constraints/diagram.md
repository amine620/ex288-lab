# Diagram 05: SCC Admission Flow and Reconciliation

```mermaid
flowchart LR
  subgraph User[User Actions]
    U1[oc apply deployment]
    U2[oc adm policy add-scc-to-user]
  end

  subgraph CP[Control Plane]
    API[API Server]
    ADM[SCC Admission]
    ETCD[(etcd)]
    DC[Deployment Controller]
    RSC[ReplicaSet Controller]
    SCH[Scheduler]
  end

  subgraph OCP[OpenShift Layer]
    SCC[SCC anyuid or restricted-v2]
    SA[ServiceAccount legacy-sa]
    RB[RoleBinding or SCC binding]
    RT[Route]
  end

  subgraph K8s[Kubernetes Layer]
    DEP[Deployment legacy-web]
    RS[ReplicaSet legacy-web hash]
    POD[Pod legacy-web]
    SVC[Service]
    KLET[Kubelet]
  end

  U1 --> API
  API --> ADM
  ADM --> SCC
  ADM --> SA
  SA --> RB

  ADM -- allow --> ETCD
  ADM -- deny --> API

  API --> DEP
  DC --> RS
  RSC --> POD
  POD --> SCH
  SCH --> KLET

  U2 --> API
  API --> RB
  RB --> SA
  SA --> SCC

  RT --> SVC
  SVC --> POD
```

Arrow meanings:

- `User -> API Server`: user submits desired state or policy change.
- `API Server -> SCC Admission`: pod requests are evaluated before persistence.
- `SCC Admission -> SCC`: policy rules are checked against pod security context.
- `SCC Admission -> ServiceAccount`: admission uses SA identity and permissions.
- `ServiceAccount -> Binding`: bindings determine which SCCs are usable.
- `Admission allow -> etcd`: accepted objects are persisted as cluster truth.
- `Admission deny -> API Server response`: rejected pod creation returns forbidden events.
- `API Server -> Deployment`: deployment object is stored and watched by controllers.
- `Deployment Controller -> ReplicaSet`: controller computes desired revision and scale.
- `ReplicaSet Controller -> Pod`: pod creation is retried through reconciliation.
- `Pod -> Scheduler -> Kubelet`: scheduled pods are started and monitored on nodes.
- `Policy change path`: SCC grant updates authorization, then next reconcile succeeds.
- `Route -> Service -> Pod`: external traffic path after pod is admitted and running.
