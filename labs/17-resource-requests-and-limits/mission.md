# Mission 17: Resource Requests and Limits

## Business Scenario

Your team runs a customer-facing API on CRC where workloads occasionally become unstable. Some pods are evicted or OOMKilled, while others consume too much CPU and impact neighboring services. You must enforce predictable resource behavior so the platform remains stable under pressure.

## Goal

Design, apply, and validate CPU and memory requests and limits for a real workload, intentionally trigger resource-related failures, troubleshoot them with OpenShift CLI evidence, and explain the internals behind scheduling, cgroups, throttling, and reconciliation.

## Constraints

- Use CRC-compatible images and low cluster footprint.
- Work in a dedicated mission project only.
- Define both requests and limits for CPU and memory.
- Reproduce at least two failure modes before final tuning.
- Validate behavior using pod status, events, restart counts, and node observations.
- Use CLI workflow (no console-only validation).

## Success Criteria

- Mission project and namespace are created and used.
- Deployment includes explicit CPU/memory requests and limits.
- You can reproduce and diagnose OOMKilled behavior.
- You can observe and explain CPU throttling effects.
- You can tune resources to stabilize rollout and runtime.
- You can explain API Server, etcd, scheduler, kubelet, and reconciliation loop roles in resource control.

## Difficulty Progression

1. Level 1 - Create: Deploy baseline app with conservative requests and limits.
2. Level 2 - Modify: Adjust resources to fit observed runtime behavior.
3. Level 3 - Break: Intentionally set invalid/insufficient values to trigger failures.
4. Level 4 - Troubleshoot: Use events, describe, logs, and rollout status to diagnose.
5. Level 5 - Explain Internals: Trace resource intent from API object to node enforcement.

## Troubleshooting Exercises (Mandatory)

- Exercise A: Memory limit too low causes OOMKilled restart loop.
- Exercise B: CPU limit too restrictive causes visible throttling/latency.
- Exercise C: Request too high prevents scheduling on CRC node capacity.
- Exercise D: Tune requests/limits and verify stable pod lifecycle.

## Deliverable

A complete `17-resource-requests-and-limits` mission with baseline deployment, intentional failures, diagnosis evidence, corrected sizing, and internals-focused explanation connecting OpenShift workflows to Kubernetes resource enforcement.