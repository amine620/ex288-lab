# Notes 05: SCC and Workload Admission

## Mission Focus

### Security Context Constraints (OpenShift)

- SCC is an OpenShift admission policy for pod security.
- SCC selection depends on user or ServiceAccount permissions.
- SCC decisions happen during pod admission at API Server time.

### ServiceAccount

- Workload identity used for admission and API authorization.
- A dedicated ServiceAccount enables least-privilege SCC grants.

## OpenShift Layer

### SCC

- Policy object defining allowed security contexts (UID, capabilities, privileged options).
- `restricted-v2` is the default hardened baseline in modern OpenShift.

### Route

- External entrypoint to a Service.
- Not required for SCC logic, but part of app exposure pattern.

### BuildConfig and ImageStream

- Build and image lifecycle features in OpenShift.
- Orthogonal to SCC, but often involved in full app delivery workflows.

## Kubernetes Layer

### Deployment

- Declares desired pod template and replica count.
- Owns ReplicaSets and rollout behavior.

### ReplicaSet

- Tries to create Pods from Deployment template.
- Repeatedly reconciles when Pod admission fails.

### Pod

- Admission target for SCC checks.
- Created only if security context is accepted.

### Service

- Stable endpoint abstraction for selected Pods.
- Becomes useful only after Pods are admitted and running.

## Relationship Summary

- Deployment -> ReplicaSet -> Pod defines desired workload state.
- SCC admission gate sits between API request and persisted Pod object.
- ServiceAccount permissions determine which SCC can be used.
- API Server, etcd, and controllers participate in a continuous reconciliation loop until convergence.
