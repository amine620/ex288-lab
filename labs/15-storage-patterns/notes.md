# Notes 15: Storage Patterns

## Mission Focus

### Ephemeral Pattern

- Best for cache, temp files, and recomputable data.
- Common implementation: `emptyDir` in a Deployment pod template.
- Lifecycle tied to pod existence.

### Persistent Pattern

- Best for business-critical state and durable records.
- Common implementation: StatefulSet with `volumeClaimTemplates`.
- Data survives pod recreation because PVC binds to PV.

## OpenShift Layer

### BuildConfig

- Produces images consumed by workloads.
- Build output is image-layer data, not runtime persistent application state.

### ImageStream

- Tracks image versions and integrates with deployment triggers.
- Image changes update workloads without replacing PVC data.

### Route

- Exposes Service externally.
- Networking path does not affect storage durability directly.

## Kubernetes Layer

### Deployment

- Manages stateless or mostly stateless replicas.
- Works well with ephemeral storage and immutable pod replacement.

### StatefulSet

- Adds stable pod identity and ordered operations.
- Pairs naturally with per-pod persistent volume claims.

### PersistentVolumeClaim and PersistentVolume

- PVC expresses desired storage.
- PV satisfies the claim through dynamic/static provisioning.

### Pod

- Runtime unit where mounts occur.
- Data durability depends on mounted volume type and write path.

### Service

- Stable network endpoint to pods.
- Does not manage state persistence.

## Troubleshooting Patterns

- Pending PVC usually points to StorageClass/provisioning mismatch.
- Running pod with missing data often means wrong write path.
- `describe` output plus events timeline is the fastest root-cause signal.

## Control Plane and Reconciliation

- API Server stores desired state in etcd.
- StatefulSet controller and Deployment controller reconcile pod state.
- PVC/PV controller reconciles claim and volume binding.
- Scheduler binds pod to node.
- Kubelet mounts storage and starts containers.
- Reconciliation loops continue until actual state matches declared state.