# Notes 03: ReplicaSets and Runtime Control

## Mission Focus

### ReplicaSet

- Maintains desired number of matching Pods.
- Uses label selector to decide Pod ownership.
- Reconciles continuously after Pod failures/deletions.

## OpenShift Layer

### BuildConfig

- OpenShift build definition for producing container images.

### ImageStream

- OpenShift image tracking abstraction that decouples image producers/consumers.

### Route

- OpenShift external access abstraction targeting Services.

## Kubernetes Layer

### Deployment

- Higher-level rollout controller that manages ReplicaSets.

### ReplicaSet

- Mid-layer workload controller ensuring Pod replica count.

### Pod

- Executable runtime unit created to satisfy ReplicaSet desired state.

### Service

- Stable network endpoint to reach Pods selected by labels.

## Relationship Summary

- Deployment -> ReplicaSet -> Pod controls rollout and scaling.
- Service -> Pod provides stable service discovery.
- Route -> Service exposes workloads externally.
- BuildConfig -> ImageStream feeds runtime image lifecycle.

## Control Plane Connection

- API Server stores ReplicaSet and Pod state in etcd.
- ReplicaSet controller watches API objects and reconciles count/ownership.
- Scheduler places new Pods.
- Kubelet runs containers and reports status updates.
