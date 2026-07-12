# Mission 14: Volumes and PVCs

## Business Scenario

Your team runs a small OpenShift-hosted reporting app on CRC. The app currently writes uploaded files to container local storage, so every pod restart causes data loss. You must redesign storage so critical files survive pod rescheduling while temporary cache data remains ephemeral.

## Goal

Implement and validate persistent and ephemeral storage patterns in OpenShift using PVC-backed volumes and emptyDir, intentionally break storage configuration, troubleshoot failures, and explain how OpenShift and Kubernetes controllers reconcile storage state.

## Constraints

- Use CRC-compatible resources and lightweight images.
- Work in a dedicated mission project.
- Use at least one PVC-backed volume and one emptyDir volume.
- Include one intentionally broken storage scenario before fixing it.
- Verify behavior through pod restarts and rollout actions.
- Use CLI workflows only.

## Success Criteria

- Project and namespace for this mission are created and isolated.
- A workload mounts an emptyDir volume for cache-like data.
- A workload mounts a PVC for durable data.
- Data written to emptyDir disappears after pod replacement.
- Data written to PVC survives pod replacement.
- At least one PVC failure scenario is reproduced and fixed.
- You can explain API Server, etcd, scheduler, PVC/PV controller, kubelet, and reconciliation loop behavior for this mission.

## Difficulty Progression

1. Level 1 - Create: Create project, workload, emptyDir, and PVC.
2. Level 2 - Modify: Resize or reconfigure storage-related manifests safely.
3. Level 3 - Break: Intentionally create a Pending PVC or failed mount scenario.
4. Level 4 - Troubleshoot: Diagnose via events, describe output, and pod status.
5. Level 5 - Explain Internals: Trace request flow from API write to controller reconciliation and kubelet mount.

## Troubleshooting Exercises (Mandatory)

- Exercise A: PVC stuck in Pending due to non-existent StorageClass.
- Exercise B: Access mode mismatch between requested claim and available provisioner behavior.
- Exercise C: Pod mount failure caused by wrong claim name in Deployment.
- Exercise D: Validate recovery by fixing manifests and forcing reconciliation.

## Deliverable

A complete `14-volumes-and-pvcs` workspace demonstrating ephemeral vs persistent behavior, one broken-and-fixed storage scenario, evidence from events/status, and internals-focused explanations.