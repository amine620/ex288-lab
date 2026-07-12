# Investigation 15: Storage Patterns Internals

Answer these after completing the lab.

1. Which resources differentiated stateless and stateful workloads in this mission?
2. Which controller created and maintained pods for each pattern (Deployment vs StatefulSet)?
3. Which controller handled PVC provisioning and binding for the StatefulSet volume claims?
4. How did you verify that ephemeral data was tied to pod lifecycle?
5. What evidence proved that persistent data survived pod replacement?
6. Which field in StatefulSet spec generated per-pod PVCs, and how did naming work?
7. Why can a pod be `Running` while persistence requirements are still not satisfied?
8. Which commands exposed the invalid StorageClass root cause most clearly?
9. How did events differ between provisioning failures and mount/path logic failures?
10. Which component mounted the PVC on the node, and where did you see that reflected?
11. What exactly was stored in etcd after each manifest apply or patch?
12. How did reconciliation loops react after you fixed the broken spec?
13. What differences did you observe between Deployment rollout and StatefulSet rollout behavior?
14. Why is StatefulSet usually preferred over Deployment for durable identity and storage?
15. What OpenShift abstractions were used, and what Kubernetes objects performed the real storage work?
16. If API Server was unavailable, which mission operations would fail first and why?
17. How would behavior change if access mode/storage class did not support your intended scaling model?
18. What troubleshooting sequence would you reuse in production for storage incidents?