# Lab 02: Build Requirements

## What You Must Build

- Create and use one mission project:
  - `team-alpha-pods`
- Create two standalone Pods:
  - One long-running diagnostics Pod
  - One command-focused Pod for log validation
- Apply clear labels and one annotation.
- Intentionally break one Pod and then recover it.

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 2 healthy standalone Pods after recovery
- Label and annotation metadata on Pods
- Event history showing failure and fix

## Expected Outcome

- You can observe Pod lifecycle states in real time.
- You can diagnose failures using status/events/logs.
- You can restore a failed Pod to running state.
- You can explain internal behavior across API Server, etcd, scheduler, kubelet, and reconciliation loops.

## Troubleshooting Scenarios To Include

- Scenario A: Pod fails with image pull error.
- Scenario B: Pod exits immediately because command is short-lived.
- Scenario C: Pod appears missing due to wrong active project.

## Completion Checklist

- Mission project created and selected
- Two standalone Pods created and verified
- One break/fix cycle completed
- Troubleshooting evidence captured
- Internals explanation completed
