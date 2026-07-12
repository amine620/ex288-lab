# Investigation 01: OpenShift Internals

Answer these after completing the lab.

1. Which Kubernetes resource is created when you create an OpenShift Project?
2. Which API object differs between `Project` and `Namespace`, and why does OpenShift expose both views?
3. Where is namespace metadata (labels/annotations) persisted?
4. Which component writes namespace objects into etcd?
5. Which controllers react after a new namespace appears?
6. Why does the `default` ServiceAccount appear in a newly created namespace without you creating it manually?
7. Which reconciliation loop is responsible for ensuring default namespace objects exist?
8. What happened in the API Server request path when you updated namespace labels?
9. How can the same workload name exist in two different namespaces without conflict?
10. Why did a workload seem missing when your current project context was wrong?
11. Which watch streams would a controller use to detect your namespace and workload changes?
12. What kubectl/oc evidence proves that the wrong-namespace troubleshooting scenario was resolved?
13. If etcd became unavailable, which mission tasks would fail first and why?
14. How does namespace isolation support multi-team platform engineering in OpenShift?
15. What assumptions did you make during troubleshooting, and which were wrong?
