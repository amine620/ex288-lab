# Lab 08: Build Requirements

## What You Must Build

- Create and use mission project:
  - `team-alpha-binary`
- Create a compiled artifact locally (simple Go binary or shell script).
- Create a Dockerfile that uses the artifact (not building from source).
- Create a binary BuildConfig that:
  - Accepts `.tar.gz` or directory input
  - Uses the Dockerfile to build the final image
  - Outputs to an ImageStream
- Use `oc start-build --from-dir` to upload the artifact.
- Verify Build pod executes and pushes image to internal registry.
- Create a Deployment that pulls and runs the binary-built image.
- Trigger intentional build failures and verify recovery.

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 1 ImageStream for binary build output
- 1 BuildConfig with binary strategy
- 1+ Build objects (build runs)
- 1 Build Pod that executes Dockerfile and pushes image
- Image persisted in internal registry with SHA256 digest
- 1 Deployment consuming the binary image
- Events and build logs showing push to registry

## Expected Outcome

- Binary artifact uploaded via `oc start-build --from-dir`.
- Build executes Dockerfile, creates image, and pushes to registry.
- ImageStream tracks image by digest and tag.
- Deployment pulls image and runs successfully.
- Build failures (missing artifact, auth, digest) are visible in logs and events.
- Registry push is confirmed with `oc get is` and `oc describe is`.

## Troubleshooting Scenarios To Include

- Scenario A: Artifact missing or wrong format; build fails immediately.
- Scenario B: Dockerfile missing or invalid; build fails during image construction.
- Scenario C: Registry push fails due to auth issues; diagnose service account permissions.
- Scenario D: Image digest mismatch; verify ImageStream tracking and pull digest.
- Scenario E: Deployment cannot pull image; check internal registry DNS and pull secret.

## Completion Checklist

- Mission project created and selected
- Binary artifact created and verified
- Dockerfile created and tested
- Binary BuildConfig created
- Artifact uploaded and build triggered successfully
- Image pushed to internal registry
- ImageStream created and image tracked by digest
- Deployment successfully uses binary-built image
- Intentional failures reproduced and diagnosed
- Build logs and registry push confirmed
- Internals explanation completed
