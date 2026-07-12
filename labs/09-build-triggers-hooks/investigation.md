# Investigation 09: Build Triggers and Hooks Internals

Answer these after completing the lab.

1. What is the difference between ConfigChange and ImageChange triggers?
2. Which OpenShift controller watches for trigger conditions and creates new Build objects?
3. When does a ConfigChange trigger fire, and what change must occur?
4. When does an ImageChange trigger fire, and how does it detect image updates?
5. What is a build hook, and at what points during a build can hooks execute?
6. How are pre-build and post-build hooks defined in BuildConfig?
7. What happens if a pre-build hook fails (non-zero exit code)?
8. What happens if a post-build hook fails?
9. Which pod executes the build hooks—a separate hook pod or the build pod itself?
10. Can a post-build hook prevent an image from being pushed to the registry? Why or why not?
11. Where are build hook logs stored, and how do you access them?
12. How does etcd track trigger configuration and which triggers have fired?
13. If a webhook is misconfigured, how would you diagnose why triggers are not firing?
14. Can multiple triggers fire for the same BuildConfig change? If so, explain how.
15. How does understanding triggers and hooks prepare you for CI/CD exam scenarios?
