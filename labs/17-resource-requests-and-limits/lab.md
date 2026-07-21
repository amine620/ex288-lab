# Lab 17: Resource Requests and Limits Requirements

## What You Must Build

- Create mission project:
  - `team-resource-controls`
- Deploy one test workload with explicit CPU/memory requests and limits.
- Collect baseline behavior under normal load.
- Intentionally break resource settings in at least two ways.
- Diagnose failures (OOMKilled, Pending due to scheduling, CPU pressure symptoms).
- Apply corrected resource values and verify recovery.

## Expected Resources

- 1 OpenShift Project and Kubernetes Namespace
- 1 Deployment
- 1 ReplicaSet and Pods managed by Deployment
- Pod events reflecting scheduling decisions and restart reasons
- Optional Service for repeatable load generation path

## Expected Outcome

- Requests influence scheduler placement decisions.
- Limits enforce runtime ceilings at node level.
- Too-low memory limit can trigger OOMKilled and restarts.
- Too-high request can keep pod Pending due to insufficient node resources.
- Reasonable tuning yields stable pod and consistent rollout.

## Troubleshooting Scenarios To Include

- Scenario A - Memory OOM:
  - Set memory limit very low and run memory-stress behavior.
  - Observe restart count and OOMKilled reason.
- Scenario B - Unschedulable Request:
  - Set CPU or memory request above CRC allocatable capacity.
  - Observe Pending pod and scheduler failure events.
- Scenario C - CPU Constriction:
  - Set CPU limit too low and compare responsiveness/throughput.
  - Explain throttling impact and recovery after tuning.

## Completion Checklist

- Mission project created and selected
- Deployment created with explicit requests and limits
- Baseline behavior captured
- At least two failure scenarios intentionally reproduced
- Root causes confirmed from events, describe, and status fields
- Resource values corrected and rollout stabilized
- Internals explanation completed (API Server, etcd, scheduler, kubelet, cgroups)
- Submission completed with command and YAML evidence

## Rules

- Do not skip failure reproduction.
- Do not treat pod phase alone as diagnosis; inspect events and reasons.
- Do not fix by blindly redeploying; identify root cause first.
- Do not rely on web console-only validation.