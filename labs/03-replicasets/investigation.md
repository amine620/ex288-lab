# Investigation 03: ReplicaSet Internals

Answer these after completing the lab.

1. Which Kubernetes object tracks desired Pod replica count in this mission?
2. Which controller watches that object and takes action when Pod count drifts?
3. Where are ReplicaSet desired state and observed status stored?
4. What evidence shows a deleted managed Pod was recreated automatically?
5. How did scheduler and kubelet contribute after ReplicaSet created replacement Pods?
6. Why can a ReplicaSet restore Pods while a standalone Pod cannot self-heal?
7. What role does the selector play in Pod ownership?
8. What happened when selector and template labels did not align?
9. Which status fields changed when scaling from 2 to 4 replicas and back?
10. Which events were most useful during troubleshooting?
11. How can you prove which Pods are owned by the ReplicaSet?
12. What API operations occurred when you edited the replica count?
13. If etcd is unavailable, which mission actions fail first and why?
14. How does this mission prepare you for Deployment behavior in the next step?
15. Which wrong assumption did you make during troubleshooting, and what corrected it?
