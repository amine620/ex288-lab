# Investigation 14: Volumes and PVC Internals

Answer these after completing the lab.

1. Which Kubernetes objects were created automatically after you submitted the PVC?
2. Which controller handled PVC to PV binding, and how can you prove it from events?
3. Which component actually mounts the volume onto the node where the Pod runs?
4. What changed in Pod status/events when the claim name was incorrect?
5. How can you distinguish provisioning failure from mount failure using CLI output?
6. Which fields in PVC status indicate successful binding?
7. What evidence shows that emptyDir lifecycle is tied to Pod lifecycle?
8. What evidence shows that PVC data lifecycle is independent from a single Pod?
9. Where is desired state for Deployment, PVC, and PV stored?
10. What is the role of API Server in each storage change you performed?
11. Which reconciliation loops were involved after you fixed the broken manifest?
12. What happens first when a pod using PVC is rescheduled to a different node?
13. How would behavior differ if a StorageClass had `WaitForFirstConsumer` binding mode?
14. Why can a Pod stay Pending even if the Deployment exists and replicas are desired?
15. What OpenShift abstractions were used in this lab, and which underlying Kubernetes resources actually enforced storage behavior?
16. Which commands gave you the most reliable signal of root cause, and why?
17. If etcd became unavailable mid-lab, which operations would fail immediately?
18. How does this mission prepare you for StatefulSets and storage troubleshooting later?