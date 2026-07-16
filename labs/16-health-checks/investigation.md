# Investigation 16: Health Checks Internals

Answer these after completing the lab.

1. Which component executes liveness/readiness/startup probes for a running container?
2. Which Kubernetes resource status fields changed when readiness failed?
3. Why can a pod be `Running` but not receive Service traffic?
4. Which controller updates Service endpoints based on pod readiness?
5. What evidence showed the difference between readiness failure and liveness failure?
6. How did restart count change during aggressive liveness settings?
7. What changed in behavior after adding startupProbe for slow startup?
8. Which events provided the clearest root-cause signal for probe failures?
9. What fields in probe spec had the biggest impact: `initialDelaySeconds`, `periodSeconds`, `failureThreshold`, or timeout?
10. How did Deployment rollout status reflect probe instability?
11. What was persisted in etcd when you patched probe configuration?
12. Which reconciliation loops acted after each probe-related spec change?
13. How can a bad readiness probe create a partial outage without crashing containers?
14. How can a bad liveness probe create unnecessary restarts even when app logic is healthy?
15. What OpenShift abstractions were involved, and which Kubernetes components enforced probe behavior?
16. If API Server becomes unavailable during troubleshooting, which operations fail first?
17. How would probe strategy differ for very slow JVM startup versus fast stateless API?
18. What production runbook steps from this mission would you reuse first in an incident?