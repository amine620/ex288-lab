# Notes 01: Concepts and Resource Relationships

## Mission-Specific Layer

### OpenShift Project

- Developer-friendly abstraction over Kubernetes Namespace.
- Adds OpenShift UX, policy hooks, and project-scoped workflows.

### Kubernetes Namespace

- Hard isolation boundary for namespaced objects.
- Names are unique within a namespace, not cluster-wide.

## OpenShift Layer (Platform Features)

### BuildConfig

- OpenShift-native build pipeline definition.
- Produces images (commonly into ImageStreams).

### ImageStream

- OpenShift image tracking and tagging abstraction.
- Decouples deployment references from external registry tags.

### Route

- OpenShift external HTTP/HTTPS exposure.
- Usually targets a Kubernetes Service.

## Kubernetes Layer (Core Runtime)

### Deployment

- Declares desired application rollout state.
- Owns ReplicaSets.

### ReplicaSet

- Maintains target number of Pods.
- Reconciles Pod count continuously.

### Pod

- Smallest schedulable runtime unit.
- Runs one or more containers.

### Service

- Stable network endpoint in front of Pods.
- Selects Pods by labels.

## How They Relate

- BuildConfig -> ImageStream: build outputs are versioned as image tags.
- Deployment -> ReplicaSet -> Pod: rollout chain for running workloads.
- Service -> Pod: stable discovery and load distribution.
- Route -> Service: external access path into cluster apps.
- Project/Namespace wraps all namespaced resources to isolate teams and environments.

## Control Plane Connection

- API Server receives object declarations.
- etcd stores desired and current resource state metadata.
- Controllers watch resources and run reconciliation loops.
- Your lab actions are concrete examples of this loop in operation.
