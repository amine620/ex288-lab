# Lab 09: Build Requirements

## What You Must Build

- Create and use mission project:
  - `team-alpha-triggers`
- Create a BuildConfig with:
  - Git source (reference a local Git repository or simulate with `--from-dir`)
  - S2I or Docker build strategy
  - ConfigChange trigger (fires when BuildConfig is modified)
  - ImageChange trigger (fires when base image is updated)
- Implement pre-build hooks that:
  - Run custom validation or setup logic before build starts
  - Exit with success/failure to demonstrate hook failure handling
- Implement post-build hooks that:
  - Run after image is successfully pushed to registry
  - Perform tagging, testing, or notification actions
- Manually trigger builds and verify hook execution in logs
- Trigger ConfigChange and ImageChange scenarios
- Verify pre/post-build hook output in build pod logs

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 1 BuildConfig with Git source and triggers
- 1+ Build objects (triggered by ConfigChange, ImageChange, or manual)
- 1 Build Pod per build with visible hook execution logs
- ImageStream tracking built images
- Events showing trigger evaluations and hook outcomes

## Expected Outcome

- ConfigChange trigger automatically starts new builds when BuildConfig is updated.
- ImageChange trigger automatically starts new builds when base ImageStream tag updates.
- Pre-build hooks execute and their output is visible in build logs.
- Post-build hooks execute after image push and their output is visible.
- Hook failures (non-zero exit code) are captured in build logs and events.
- Manual builds can be triggered and immediately show trigger/hook activity.

## Troubleshooting Scenarios To Include

- Scenario A: Pre-build hook script fails; build is aborted before Docker/S2I step.
- Scenario B: Post-build hook script fails; build succeeds but hook failure is logged.
- Scenario C: ImageChange trigger does not fire; verify ImageStream reference and tag.
- Scenario D: ConfigChange trigger fires repeatedly; investigate BuildConfig generation logic.
- Scenario E: Hook timeout; verify hook execution time and timeout settings.

## Completion Checklist

- Mission project created and selected
- BuildConfig created with Git source and S2I/Docker strategy
- ConfigChange trigger configured and tested
- ImageChange trigger configured and tested
- Pre-build hook script created and executed
- Post-build hook script created and executed
- Manual builds triggered and hook logs captured
- Intentional hook failures reproduced and diagnosed
- Build events showing trigger and hook activity logged
- Internals explanation completed
