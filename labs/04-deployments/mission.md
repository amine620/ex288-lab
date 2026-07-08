# Mission 04: Deployments

## Business Scenario

Your team needs safe rollout control for an internal API on CRC. ReplicaSets gave self-healing, but the team now needs versioned rollout history, controlled updates, and rollback capability to reduce deployment risk.

## Goal

Create and operate a Kubernetes Deployment in OpenShift, perform a rolling update, intentionally trigger a bad rollout, recover with rollback, and explain internal reconciliation behavior.

## Constraints

- Use CRC-compatible images and low resource usage.
- Work in a dedicated mission project.
- Use Deployment as the primary controller (not raw Pod management).
- Keep all steps reproducible from a clean CRC start.

## Success Criteria

- A mission project exists and is used for all resources.
- One Deployment manages application Pods through a ReplicaSet.
- A successful rolling update is completed and verified.
- A failed rollout is intentionally created and recovered.
- You can explain interactions among API Server, etcd, Deployment controller, ReplicaSet controller, scheduler, kubelet, and reconciliation loops.

## Difficulty Progression

1. Level 1 - Create: Create Deployment with 2 replicas.
2. Level 2 - Modify: Perform a rolling image update.
3. Level 3 - Break: Introduce a bad image tag to fail rollout.
4. Level 4 - Troubleshoot: Diagnose rollout status/events and rollback.
5. Level 5 - Explain Internals: Describe how Deployment manages ReplicaSets and Pod convergence.

## Deliverable

A `04-deployments` lab workspace with deployment revision history, one successful update, one failed update with rollback, and investigation answers focused on internals.
