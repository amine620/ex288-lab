# Notes 17: Requests, Limits, and Runtime Enforcement

## Mission Focus

### Requests

- Minimum guaranteed resources used by scheduler for placement.
- If requests are too high, pod may stay Pending.

### Limits

- Maximum resources container can consume.
- Memory limit breaches can trigger OOMKilled.
- CPU limit overages are throttled rather than killed.

### OOMKilled

- Container exceeds memory limit and is terminated.
- Restart behavior depends on pod restart policy and controller reconciliation.

### CPU Throttling

- Enforced through cgroup CPU quota.
- App stays running but may become slow under load.

## OpenShift Layer

### BuildConfig

- Produces container images consumed by deployments.
- Build pod resources can also be constrained with requests and limits.

### ImageStream

- Tracks image tags and revisions used by workloads.
- Resource policies are separate from image tracking.

### Route

- Exposes service externally.
- Route does not control pod resources; deployment spec does.

## Kubernetes Layer

### Deployment

- Holds desired pod template including resources.
- Template changes create new rollout revisions.

### ReplicaSet

- Maintains pod count for one deployment revision.
- Recreates pods when failures occur.

### Pod

- Runtime unit where resource constraints are enforced.
- Container status shows OOMKilled and restart information.

### Service

- Stable access endpoint to matching pods.
- Service availability still depends on pod health and capacity.

## Relationship Summary

- BuildConfig can publish image to ImageStream.
- Deployment consumes image and defines requests and limits.
- ReplicaSet creates pods with those constraints.
- Scheduler places pods based on requests.
- Kubelet enforces limits with cgroups.
- Service and Route provide connectivity to running pods.

## Control Plane and Reconciliation

- API Server persists desired state to etcd.
- Deployment and ReplicaSet controllers reconcile replica state.
- Scheduler decides placement feasibility using requests.
- Kubelet enforces limits and reports runtime outcomes.
- Events and status fields expose failure and recovery timelines.