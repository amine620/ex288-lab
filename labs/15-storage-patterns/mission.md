# Mission 15: Storage Patterns

## Business Scenario

Your team is preparing two OpenShift workloads on CRC:

- a stateless API that can lose cache safely
- a stateful order service that must preserve records across pod recreation

Recent incidents showed engineers mounting the wrong storage type, causing data loss for critical paths and unnecessary PVC usage for temporary data. You must design and validate the right storage pattern per workload and prove why each choice is correct.

## Goal

Implement and compare ephemeral and persistent storage patterns in OpenShift, intentionally break storage behavior, troubleshoot with CLI evidence, and explain how Kubernetes controllers and reconciliation loops restore desired state.

## Constraints

- Use CRC-compatible images and lightweight manifests.
- Work in a dedicated mission project only.
- Use one Deployment with ephemeral storage and one StatefulSet with persistent storage.
- Keep stateful workload replica count at 1 for CRC capacity.
- Include at least two intentional failure scenarios before final recovery.
- Use CLI-first workflow and capture evidence from status and events.

## Success Criteria

- Mission project and namespace are created and isolated.
- Deployment uses ephemeral storage pattern appropriately.
- StatefulSet uses PVC-backed persistent storage.
- You prove ephemeral data loss after pod replacement.
- You prove persistent data survival after pod replacement.
- Two storage failures are reproduced and fixed.
- You explain API Server, etcd, PVC/PV controller, StatefulSet controller, scheduler, kubelet, and reconciliation loop behavior.

## Difficulty Progression

1. Level 1 - Create: Build both storage patterns (ephemeral and persistent).
2. Level 2 - Modify: Patch storage requests and validate behavior changes.
3. Level 3 - Break: Introduce claim/template mistakes intentionally.
4. Level 4 - Troubleshoot: Use describe/events/logs to isolate root cause.
5. Level 5 - Explain Internals: Trace control-plane and node-level actions end-to-end.

## Troubleshooting Exercises (Mandatory)

- Exercise A: StatefulSet PVC remains Pending due to invalid StorageClass.
- Exercise B: Volume mount path mismatch writes data to container layer instead of PVC.
- Exercise C: Pod restart appears successful but persistent test fails due to wrong write path.
- Exercise D: Recovery validation using rollout/restart and event timeline.

## Deliverable

A complete `15-storage-patterns` mission showing correct pattern selection, broken-and-fixed cases, verification evidence, and an internals explanation focused on OpenShift plus underlying Kubernetes resources.