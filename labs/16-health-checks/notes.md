# Notes 16: Health Checks

## Mission Focus

### Startup Probe

- Protects slow-start applications from premature liveness failures.
- While startup probe is failing, readiness and liveness are not enforced the same way.
- Use it to cover worst-case initialization time.

### Readiness Probe

- Controls whether pod receives Service traffic.
- Failed readiness does not kill container.
- Pod can be Running but excluded from endpoints.

### Liveness Probe

- Detects deadlocked/unhealthy process and triggers container restart.
- Too aggressive settings can create restart storms.
- Should represent true process health, not startup readiness.

## OpenShift Layer

### BuildConfig

- Builds container images that eventually run with probes.
- Build success does not guarantee runtime health behavior.

### ImageStream

- Tracks image tags and can trigger deployment updates.
- New image revision can require probe tuning.

### Route

- Exposes Service externally.
- Route health is indirectly affected by pod readiness through Service endpoints.

## Kubernetes Layer

### Deployment

- Declares desired pods and probe config in pod template.
- Any probe patch creates a new ReplicaSet revision.

### ReplicaSet

- Maintains pod count for each deployment revision.
- Probe outcomes influence availability during rollout.

### Pod

- Contains container plus probe state and readiness conditions.
- Kubelet updates pod conditions based on probe results.

### Service and Endpoints

- Service selects pods by labels.
- Endpoints include only Ready pods for traffic routing.

## Troubleshooting Patterns

- Running but no traffic usually means readiness failure.
- Frequent restarts usually indicate liveness misconfiguration or real crashes.
- Probe events in `describe pod` are the fastest signal.

## Control Plane and Reconciliation

- API Server persists desired probe specs in etcd.
- Deployment and ReplicaSet controllers reconcile template changes.
- Kubelet executes probes and updates pod status.
- Endpoints controller reconciles ready addresses for Services.
- Reconciliation loops continuously enforce desired availability behavior.