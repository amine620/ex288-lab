# Notes 04: Deployment Control and Rollouts

## Mission Focus

### Deployment

- Declarative controller for application rollout and updates.
- Manages ReplicaSets and rollout history.
- Supports rollback after failed revisions.

### ReplicaSet

- Maintains Pod count for a specific revision.
- Deployment scales old/new ReplicaSets during rollout.

## OpenShift Layer

### BuildConfig

- Build process definition for source-to-image workflows.

### ImageStream

- OpenShift-native image tracking and tag history.

### Route

- Exposes service traffic externally in OpenShift.

## Kubernetes Layer

### Deployment

- Owns rollout strategy and revision lifecycle.

### ReplicaSet

- Owns Pods for one rollout revision.

### Pod

- Runtime execution unit created via ReplicaSet reconciliation.

### Service

- Stable endpoint selecting Pods regardless of revision churn.

## Relationship Summary

- Deployment -> ReplicaSet -> Pod orchestrates controlled updates.
- Service -> Pod provides stable access through pod replacement.
- Route -> Service provides external access path.
- BuildConfig -> ImageStream can feed application image updates.

## Control Plane Connection

- API Server stores desired rollout state in etcd.
- Deployment controller computes rollout actions.
- ReplicaSet controller enforces replica counts.
- Scheduler places new Pods and kubelet executes containers.
