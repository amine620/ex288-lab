# Lab 15: Storage Patterns Requirements

## What You Must Build

- Create mission project:
  - `team-storage-patterns`
- Build a stateless workload using ephemeral storage only.
- Build a stateful workload using PVC-backed storage.
- Demonstrate persistence behavior difference after pod recreation.
- Intentionally introduce at least two storage failures.
- Troubleshoot and recover to healthy workloads.

## Expected Resources

- 1 OpenShift Project and Kubernetes Namespace
- 1 Deployment for stateless API/cache pattern
- 1 StatefulSet for persistent pattern
- 1 Headless Service for StatefulSet identity
- 1 ClusterIP Service for app access
- 1 or more PersistentVolumeClaims
- Dynamically provisioned PersistentVolumes
- Pods for both workloads
- Events showing provision, scheduling, mount, and failure recovery

## Expected Outcome

- Stateless pod data disappears after recreation when stored in ephemeral path.
- Stateful pod data remains after recreation when stored in PVC path.
- Broken StorageClass and path-miswrite scenarios are diagnosed with evidence.
- Corrected manifests reconcile and workloads become Ready.

## Troubleshooting Scenarios To Include

- Scenario A - Invalid StorageClass:
  - PVC remains `Pending`.
  - Capture claim events and explain provisioning failure.
- Scenario B - Wrong Data Path:
  - App writes outside mounted PVC path.
  - Pod appears healthy but persistence check fails.
- Scenario C - StatefulSet Recovery:
  - Fix spec and force reconciliation.
  - Validate data continuity after recovery.

## Completion Checklist

- Mission project created and selected
- Stateless Deployment created with ephemeral storage
- StatefulSet created with persistent volume claims
- Data behavior comparison recorded
- Two intentional failure scenarios reproduced
- Root causes identified from events/descriptions
- Fixes applied and reconciliation verified
- Internal architecture explained (API Server, etcd, controllers, kubelet)
- Submission completed with command evidence

## Rules

- Do not skip failure reproduction.
- Do not rely only on Ready status; validate actual data paths.
- Do not treat delete/recreate as first troubleshooting step.
- Do not use web console-only evidence.