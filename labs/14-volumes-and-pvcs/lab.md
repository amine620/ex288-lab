# Lab 14: Volumes and PVCs Requirements

## What You Must Build

- Create and use mission project:
  - `team-volumes-pvcs`
- Build one application workload with two storage paths:
  - Path A backed by `emptyDir` for transient cache
  - Path B backed by `PersistentVolumeClaim` for durable files
- Generate clear proof of behavior difference after pod restart/recreate.
- Introduce and troubleshoot at least one broken PVC scenario.
- Recover to a healthy state and verify volume mounts.

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 1 Deployment managing application Pods
- 1 Service for internal access (optional but recommended)
- 1 PVC for persistent storage
- Dynamically provisioned PV created from the PVC (CRC default provisioner)
- 1 or more Pods mounting both volume types
- Events demonstrating provisioning, attach/mount, and failure/recovery

## Expected Outcome

- Pod writes data to both transient and persistent paths.
- After pod recreation:
  - `emptyDir` data is lost.
  - PVC data remains available.
- Broken claim scenario is reproduced and diagnosed from status/events.
- Corrective changes cause claim binding and pod readiness recovery.

## Troubleshooting Scenarios To Include

- Scenario A - Pending PVC:
  - Claim requests a non-existent StorageClass.
  - Observe `Pending` state and provisioning failure events.
- Scenario B - Mount Reference Error:
  - Deployment references the wrong PVC name.
  - Observe pod events and container waiting reason.
- Scenario C - Access/Capacity Validation:
  - Request storage/access mode that does not fit expected environment behavior.
  - Record scheduler/controller feedback and adjust claim spec.

## Completion Checklist

- Mission project created and selected
- Deployment created with both `emptyDir` and PVC mounts
- Data persistence test executed and documented
- At least one failure scenario intentionally introduced
- Root cause identified using events/descriptions
- Fix applied and reconciliation verified
- Internals explanation completed (API Server, etcd, controllers, kubelet)
- Submission file completed with command evidence and observations

## Rules

- Do not skip failure reproduction.
- Do not rely on web console-only checks.
- Do not delete and recreate everything as first response to failure; diagnose first.