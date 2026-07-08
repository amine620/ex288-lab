# Mission 08: Binary Builds

## Business Scenario

Your team builds a compiled Go application locally on their dev machine. You cannot rely on Git clone + S2I builds during the exam. You need to build the artifact outside CRC, then push the compiled binary into a container image in the OpenShift internal registry, and deploy it without rebuilding inside the cluster.

Your mission: Create a binary build workflow—compile an application locally, use `oc start-build --from-dir` or `oc start-build --from-file` to send the artifact to OpenShift, let Dockerfile build the final image, push to internal registry, track the image in ImageStream, and deploy the result.

## Goal

Understand binary builds as an alternative to source-to-image (S2I), learn when to use binary vs S2I, push pre-built artifacts to the internal registry, trigger image tagging in ImageStream, and explain how BuildConfig, Build, ImageStream, and the image registry controller interact during a binary build workflow.

## Constraints

- Use CRC-compatible workflow and low resource usage.
- Work in a dedicated mission project.
- Build a simple compiled artifact (Go or similar) on the host.
- Use Dockerfile to layer the artifact into a runtime image.
- Push to the OpenShift internal registry only (not external DockerHub).
- Do NOT use `docker build` or external registries; simulate what the exam allows.
- Keep all steps reproducible from a clean CRC start.

## Success Criteria

- A binary BuildConfig is created and accepts `.tar.gz` or `.zip` artifacts.
- A compiled artifact is successfully sent to BuildConfig using `oc start-build --from-dir`.
- A Build object is created and executes a Dockerfile that includes the artifact.
- The resulting image is pushed to the internal registry.
- The image is tracked in an ImageStream with correct SHA256 digest.
- A Deployment consumes the binary-built image successfully.
- You can explain why binary builds are useful and how they differ from S2I.
- You can describe the registry API interactions and ImageStream controller reconciliation.

## Difficulty Progression

1. Level 1 - Create: Set up binary BuildConfig and create a compiled artifact.
2. Level 2 - Modify: Adjust Dockerfile and re-push artifact.
3. Level 3 - Break: Trigger build failure (missing artifact, registry auth, digest mismatch).
4. Level 4 - Troubleshoot: Diagnose build logs, registry push failures, and image pull errors.
5. Level 5 - Explain Internals: Describe build pod lifecycle, registry auth, and ImageStream image tracking.

## Deliverable

A complete `08-binary-builds` lab workspace with working binary build flow, intentional failure scenarios, recovery steps, and internals-focused explanations.
