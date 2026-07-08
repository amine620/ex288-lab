# Mission 02: Pods

## Business Scenario

Your team needs a pre-deployment diagnostics workload on CRC before introducing ReplicaSets and Deployments. You must prove that you can create and inspect raw Pods, identify failures quickly, and explain what OpenShift and Kubernetes components did behind the scenes.

## Goal

Create standalone Pods in an isolated project, intentionally break one Pod, recover it, and explain the internal control-plane flow for each lifecycle step.

## Constraints

- Use CRC-compatible images and minimal resource usage.
- Work only in a mission-specific project.
- Start with standalone Pods (no Deployment or ReplicaSet objects in this mission).
- Keep all tasks reproducible from a clean CRC session.

## Success Criteria

- A dedicated project for this mission exists.
- Two standalone Pods are created and observed.
- One Pod is intentionally broken and then recovered.
- Troubleshooting evidence is collected (events, describe output, logs).
- You can explain the role of API Server, etcd, scheduler, kubelet, and reconciliation behavior.

## Difficulty Progression

1. Level 1 - Create: Create and inspect standalone Pods.
2. Level 2 - Modify: Recreate Pods with updated labels/command behavior.
3. Level 3 - Break: Introduce a failure (invalid image or command).
4. Level 4 - Troubleshoot: Diagnose via events and object status, then fix.
5. Level 5 - Explain Internals: Map every step to control-plane components and watchers.

## Deliverable

A `02-pods` lab workspace with healthy Pods, one documented failure-and-recovery cycle, and investigation answers focused on internals.
