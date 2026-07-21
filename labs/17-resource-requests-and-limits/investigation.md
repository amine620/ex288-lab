# Investigation 17: Resource Control Internals

Answer these after completing the lab.

1. Which fields in the Pod spec carried CPU/memory requests and limits?
2. Which component used requests to decide whether the Pod could be scheduled?
3. Which command output best proved why a Pod stayed Pending?
4. How did you confirm an OOMKilled event versus a regular crash?
5. Which status fields changed when the container was repeatedly restarted?
6. How can you distinguish CPU throttling symptoms from memory exhaustion symptoms?
7. Where are desired resource values persisted after oc apply?
8. Which controller reacted to your Deployment template change?
9. What role did the ReplicaSet controller play during each revision?
10. What role did kubelet play after the scheduler assigned a node?
11. How did events help reconstruct the timeline of failure and recovery?
12. Which observations indicate reconciliation succeeded after resource tuning?
13. What tradeoff did you observe between low limits and application responsiveness?
14. Why can high requests block scheduling even when current usage seems low?
15. What happens first if etcd is unavailable when you try to patch resource values?
16. Which OpenShift-layer objects are adjacent to this workflow, and which Kubernetes resources actually enforce CPU/memory controls?
17. If you added HorizontalPodAutoscaler later, how would requests/limits influence autoscaling behavior?
18. How does this mission prepare you for quota and limit range policies in the next topic?