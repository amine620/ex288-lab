# Lab 16: Health Checks Requirements

## What You Must Build

- Create mission project:
  - `team-health-checks`
- Deploy one application with HTTP health endpoints.
- Configure startup, readiness, and liveness probes.
- Expose app with a Service and verify ready endpoints.
- Intentionally break probe settings in at least two ways.
- Troubleshoot, fix, and verify stable behavior.

## Expected Resources

- 1 OpenShift Project and Kubernetes Namespace
- 1 Deployment
- 1 ReplicaSet and Pods managed by Deployment
- 1 Service selecting app pods
- Endpoints/EndpointSlice entries reflecting readiness state
- Events showing probe failures and recoveries

## Expected Outcome

- Pod becomes Ready only after readiness checks pass.
- Service endpoints include pod only when readiness is healthy.
- Liveness failures trigger restarts with observable restart count.
- Startup probe gates liveness/readiness checks during cold start.
- Broken probe scenarios are reproduced and resolved with evidence.

## Troubleshooting Scenarios To Include

- Scenario A - Wrong readiness path:
  - Pod phase is Running but Ready is false.
  - Service endpoint excludes pod.
- Scenario B - Aggressive liveness timing:
  - Frequent restarts and rollout instability.
- Scenario C - Startup gap:
  - Slow-start app fails liveness without startup probe.
  - Add startup probe and validate stabilization.

## Completion Checklist

- Mission project created and selected
- Baseline deployment with all three probes created
- Service and endpoint behavior validated
- Two or more probe failures intentionally reproduced
- Root causes identified from events/describe/logs
- Probe configuration fixed and rollout stabilized
- Internal architecture explained (API Server, etcd, controllers, kubelet)
- Submission completed with command/YAML evidence

## Rules

- Do not skip failure reproduction.
- Do not rely on pod phase only; check readiness and endpoints.
- Do not treat repeated redeploy as first troubleshooting method.
- Do not use web console-only validation.