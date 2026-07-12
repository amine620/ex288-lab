# Investigation 02: Pod Internals

Answer these after completing the lab.

1. Which Kubernetes API object did you create when issuing Pod creation commands?
2. Which component accepted and persisted that object first?
3. Where is the Pod spec and status data stored after creation?
4. Which scheduler decision proves node assignment happened?
5. What is kubelet responsible for after the Pod is assigned?
6. Why does a standalone Pod not self-heal when deleted?
7. Which event reason explained your intentional failure most clearly?
8. What practical difference did you observe between `ErrImagePull` and `ImagePullBackOff`?
9. Why did one Pod terminate quickly in the short-command scenario?
10. Which status fields changed during `Pending` to `Running` transition?
11. Which controllers or watchers reacted during your Pod lifecycle changes?
12. What command output proves your Pod fix was successful?
13. What would fail first in this mission if etcd were unavailable?
14. How does this mission prepare you for ReplicaSet reconciliation behavior?
15. Which troubleshooting assumption was wrong initially, and how did you correct it?
