# Investigation 04: Deployment Internals

Answer these after completing the lab.

1. Which API object owns rollout strategy and revision history in this mission?
2. Which controller creates new ReplicaSets during image update?
3. How can you prove which ReplicaSet is active after update?
4. What status fields on Deployment changed during rollout?
5. How does maxUnavailable and maxSurge affect rolling update behavior?
6. Why do old ReplicaSets remain after rollout completion?
7. Which event/message best indicated a failed rollout?
8. What differences did you observe between `rollout status` and Pod-level events?
9. What API changes occurred when you executed rollback?
10. How does the ReplicaSet controller participate after Deployment creates a new ReplicaSet?
11. Which component actually schedules new Pods to the node?
12. What role does kubelet play after scheduling?
13. Where are Deployment revisions and desired state persisted?
14. If etcd were unavailable, which deployment operations fail first?
15. How does this mission prepare you for advanced deployment strategies later?
