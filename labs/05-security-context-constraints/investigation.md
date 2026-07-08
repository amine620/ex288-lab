# Investigation 05: SCC Internals

Answer these after completing the lab.

1. Which API object stores the pod spec that triggered SCC denial?
2. At what stage does SCC evaluation happen: before scheduling or after scheduling?
3. Which component decides whether the pod can run as UID 0?
4. Why can a Deployment and ReplicaSet exist while no Pod is created successfully?
5. Which event messages prove SCC admission denial?
6. Which ServiceAccount did your Deployment use before and after the fix?
7. Which SCC was selected after the targeted grant, and why that one?
8. What changed in authorization objects when you granted SCC access?
9. What is persisted in etcd before fix vs after fix?
10. Which controllers continue reconciling while admission keeps failing?
11. Why is granting SCC to a dedicated ServiceAccount safer than granting broadly?
12. What is the risk of granting `anyuid` to `system:authenticated`?
13. If API Server is reachable but etcd is unavailable, what SCC-related actions fail?
14. How does this mission connect to EX288 troubleshooting under time pressure?
15. What would be your rollback plan if an SCC grant was too broad?
