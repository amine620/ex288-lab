# Investigation 10: Build Troubleshooting Internals

Answer these after completing the lab.

1. What happens to a Build Pod after the build completes?
2. Why are build pod logs sometimes inaccessible after a build fails?
3. How does the Build Controller reconcile a failed Build object?
4. What is the difference between a failed build (Build.status.phase = Failed) and a build pod CrashLoopBackOff?
5. How does OpenShift distinguish between a git clone failure and an S2I assemble failure in logs?
6. What is stored in etcd for a failed Build, and how does it persist failure reason?
7. How does the builder pod (S2I) report errors back to the Build object?
8. Can a build pod be reused for multiple builds, or is one pod created per build?
9. Where is the builder image sourced, and what happens if the image cannot be pulled?
10. How do you access a build pod's logs if the pod has already been deleted?
11. What role does the ServiceAccount play in registry authentication failures?
12. If a Git repository requires SSH authentication, where are SSH credentials stored in OpenShift?
13. How does the Build Controller detect and respond to transient failures (e.g., network timeouts)?
14. Can a failed build be retried automatically, or must the user trigger a new build?
15. How does understanding build troubleshooting prepare you for debugging production CI/CD issues on EX288?
