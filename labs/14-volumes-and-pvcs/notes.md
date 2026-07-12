# Notes 14: Volumes and PVCs

## Mission Focus

### emptyDir

- Ephemeral volume created when Pod starts.
- Lives on node storage.
- Deleted when Pod is removed.

### PersistentVolumeClaim (PVC)

- Request for storage capacity and access mode.
- Bound to a PersistentVolume (PV) by control-plane logic.
- Data survives Pod replacement when mounted again.

### PersistentVolume (PV)

- Backing storage resource satisfying a claim.
- In CRC, often dynamically provisioned by default StorageClass.

## OpenShift Layer

### BuildConfig

- OpenShift build definition that can produce application images.
- Not a storage primitive, but often writes artifacts to image layers or mounted volumes during builds.

### ImageStream

- Tracks image versions/tags inside OpenShift.
- Deployment updates can consume ImageStream tags while app data remains in PVC.

### Route

- Exposes Service externally.
- Route handles network access, not storage; app state should still be stored in PVC.

## Kubernetes Layer

### Deployment

- Declares desired pod template and replica count.
- References volumes and mounts in pod spec.

### ReplicaSet

- Ensures the required number of Pods for a Deployment revision.
- New Pods must successfully mount required PVCs to become Ready.

### Pod

- Runtime unit where volume mounts happen.
- Uses emptyDir for temporary data and PVC for persistent data.

### Service

- Stable endpoint to Pods.
- Service does not preserve state; persistent state belongs in PVC-backed storage.

## Relationship Summary

- BuildConfig can build app image into ImageStream.
- Deployment consumes image and creates ReplicaSet.
- ReplicaSet creates Pods.
- Pods mount emptyDir (ephemeral) and PVC (persistent).
- Service targets Pods for internal traffic.
- Route exposes Service externally.

## Control Plane and Reconciliation

- API Server stores desired specs in etcd.
- PVC/PV controller watches claims and binds/provisions volumes.
- Deployment controller and ReplicaSet controller maintain desired Pods.
- Scheduler assigns Pod to a node.
- Kubelet mounts declared volumes and starts containers.
- Reconciliation loops continuously push actual state toward desired state.