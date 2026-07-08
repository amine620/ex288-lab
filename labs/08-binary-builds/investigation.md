# Investigation 08: Binary Builds and Registry Internals

Answer these after completing the lab.

1. What is the primary difference between binary builds and S2I builds in BuildConfig?
2. Which Kubernetes object represents a single build run, and which owns it?
3. What is the build pod, and which ServiceAccount does it run as?
4. How does the build pod authenticate to push images to the internal registry?
5. Where does `oc start-build --from-dir` send the artifact, and how is it accessed by the build pod?
6. What role does ImageStream play after a successful binary build?
7. How are image digests (SHA256) computed, and where are they stored?
8. Can a build pod fail to push to the registry if auth is correct? What else could go wrong?
9. Which controller watches for image pushes and updates ImageStream status?
10. How does etcd track both the BuildConfig desired state and the completed Build object?
11. When is a Build object transitioned to Succeeded or Failed status?
12. What happens if the Dockerfile in a binary build does not COPY the artifact?
13. How does the internal registry differ from external registries in terms of discovery and auth?
14. Can you pull a binary-built image by digest before it is tagged? Why or why not?
15. How does this mission prepare you for exam scenarios where you cannot push to external registries?
