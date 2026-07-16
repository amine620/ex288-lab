# Mission 16: Health Checks and Probe Strategy

## Business Scenario

Your platform team runs a customer API on OpenShift CRC. Recent incidents showed two dangerous patterns:

- traffic was sent to pods before the app was actually ready
- liveness probes restarted pods repeatedly during slow startup

You must design and validate a probe strategy using startup, readiness, and liveness probes so rollout behavior is safe and failures are diagnosable.

## Goal

Implement robust health checks for a deployed application, intentionally misconfigure probes to reproduce failure modes, troubleshoot using OpenShift CLI evidence, and explain the full control-plane and node-level flow behind probe-driven behavior.

## Constraints

- Use CRC-compatible resources and lightweight container images.
- Work in a dedicated mission project only.
- Use all three probe types: startup, readiness, liveness.
- Include at least two intentional probe misconfigurations before final fix.
- Validate behavior using events, rollout status, and endpoint readiness.
- Use CLI-first workflow.

## Success Criteria

- Project/namespace for the mission is created.
- Application Deployment includes startup, readiness, and liveness probes.
- Readiness controls traffic eligibility correctly.
- Liveness restarts truly unhealthy containers only.
- Startup probe prevents premature liveness failures during boot.
- At least two probe failures are reproduced and fixed.
- You can explain API Server, etcd, Deployment/ReplicaSet controllers, Endpoints controller, kubelet probe loop, and reconciliation behavior.

## Difficulty Progression

1. Level 1 - Create: Deploy app and add baseline probe configuration.
2. Level 2 - Modify: Tune thresholds/paths/ports to align with app behavior.
3. Level 3 - Break: Introduce wrong path/port/timing to trigger failures.
4. Level 4 - Troubleshoot: Diagnose with describe/events/logs and recover.
5. Level 5 - Explain Internals: Trace probe state to Service endpoint changes and rollout impact.

## Troubleshooting Exercises (Mandatory)

- Exercise A: Readiness probe points to wrong path, pod runs but stays unready.
- Exercise B: Liveness probe too aggressive causes restart loop.
- Exercise C: Missing startup probe for slow boot leads to false liveness failures.
- Exercise D: Fix probes and verify endpoint recovery and stable rollout.

## Deliverable

A complete `16-health-checks` mission showing correct probe strategy, intentional failures, recovery verification, and an internals-focused explanation connecting OpenShift workflows to underlying Kubernetes controllers.