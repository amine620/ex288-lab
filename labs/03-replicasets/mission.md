# Mission 03: ReplicaSets

## Business Scenario

Your platform team observed that standalone Pods are fragile for shared environments. A test service must stay available in CRC even when Pods are deleted or fail. You need a controller that continuously restores desired Pod count.

## Goal

Build and operate a Kubernetes ReplicaSet directly in OpenShift, then prove self-healing and scale behavior while explaining control-plane internals.

## Constraints

- Use CRC-compatible images with minimal resource consumption.
- Work in an isolated mission project.
- Use ReplicaSet directly (do not use Deployment in this mission).
- Keep all actions reproducible from a clean CRC session.

## Success Criteria

- A mission-specific project exists and is used consistently.
- One ReplicaSet maintains a stable number of Pods.
- You scale the ReplicaSet up and down successfully.
- You intentionally break selector/template behavior and recover.
- You explain how API Server, etcd, controllers, scheduler, kubelet, and reconciliation loops produced observed outcomes.

## Difficulty Progression

1. Level 1 - Create: Create a ReplicaSet with 2 replicas.
2. Level 2 - Modify: Scale and relabel correctly while preserving ownership.
3. Level 3 - Break: Introduce label-selector mismatch or delete managed Pods intentionally.
4. Level 4 - Troubleshoot: Diagnose events/status and restore healthy reconciliation.
5. Level 5 - Explain Internals: Map controller decisions and state transitions to control-plane components.

## Deliverable

A `03-replicasets` lab workspace with one healthy ReplicaSet, documented break/fix evidence, and investigation answers focused on internals.
