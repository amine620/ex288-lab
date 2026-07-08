# Notes 02: Pod Concepts and Resource Layers

## Mission Focus

### Standalone Pod

- Smallest schedulable Kubernetes workload unit.
- Good for diagnostics and learning internals.
- Not self-healing without higher-level controller ownership.

## OpenShift Layer

### BuildConfig

- Defines source-to-image build logic.
- Produces images commonly referenced through ImageStreams.

### ImageStream

- Tracks image tags inside OpenShift.
- Decouples workload references from external registry details.

### Route

- Exposes HTTP/HTTPS traffic to Services.
- Provides external access path for applications.

## Kubernetes Layer

### Deployment

- Desired-state manager for stateless apps.
- Creates and updates ReplicaSets.

### ReplicaSet

- Maintains desired Pod replica count.
- Recreates Pods when drift is detected.

### Pod

- Runs one or more containers with shared network/storage namespace.
- Scheduled by scheduler and executed by kubelet.

### Service

- Stable virtual endpoint selecting Pods via labels.
- Shields clients from Pod recreation and IP changes.

## Relationship Summary

- BuildConfig -> ImageStream: build output tracking.
- Deployment -> ReplicaSet -> Pod: runtime control chain.
- Service -> Pod: stable discovery/load distribution.
- Route -> Service: external entry to workloads.

## Control Plane Connection

- API Server receives and validates object changes.
- etcd persists desired and observed states.
- Scheduler assigns Pods to nodes.
- Kubelet reconciles node-local container state.
- Reconciliation loops keep observed state aligned with desired declarations.
