# Lab 10: Build Troubleshooting Requirements

## What You Must Build

- Create and use mission project:
  - `team-troubleshoot-builds`
- Create multiple BuildConfigs and intentionally break them:
  - BuildConfig A: **Git clone failure** (bad URI or missing auth)
  - BuildConfig B: **S2I assemble failure** (missing assemble script or script error)
  - BuildConfig C: **Registry push failure** (missing ServiceAccount credentials)
  - BuildConfig D: **Successful build** (baseline for comparison)
- Run builds and capture failure logs
- Use `oc logs`, `oc describe`, `oc get events` to diagnose
- Fix each failure and verify success

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 4 BuildConfig objects (one per scenario)
- 4+ Build objects (from running scenarios multiple times)
- Build Pods with visible failure logs
- Events showing build failures, retries, and completions
- ImageStreams tracking attempted image pushes

## Expected Outcome

- Build pod logs are accessible via `oc logs <build-pod-name>`.
- Error messages clearly indicate root cause (Git auth, assemble error, push failure).
- Events show build status transitions and controller decisions.
- Fixed BuildConfigs successfully complete builds.
- Failed builds are marked as Failed/Error in etcd with reason visible via `oc describe`.

## Troubleshooting Scenarios To Include

- **Scenario A - Git Clone Failure**: BuildConfig references non-existent Git URI.
  - Error: "fatal: unable to access 'https://...' "
  - Diagnosis: Check Git URI in BuildConfig.
- **Scenario B - Missing Assemble Script**: S2I builder image expects assemble but repo doesn't provide it.
  - Error: "assemble: command not found" or "assemble failed"
  - Diagnosis: Verify repo structure or builder image expectations.
- **Scenario C - Registry Push Failure**: BuildConfig output target but Pod lacks credentials.
  - Error: "denied: access forbidden" or "no auth credentials"
  - Diagnosis: Check ServiceAccount docker-cfg secret.
- **Scenario D - Resource Quota Exceeded**: Build pod cannot start due to project limits.
  - Error: "Pod failed to start" / "quota exceeded"
  - Diagnosis: Check resource limits and project quotas.
- **Scenario E - Build Pod Logs Cleanup**: Build pod logs disappear after pod deletion.
  - Diagnosis: Access logs before pod cleanup via `oc logs --tail=0`.

## Completion Checklist

- Mission project created and selected
- 4 BuildConfigs created (3 broken, 1 working)
- Builds triggered and failures captured
- Logs analyzed for each failure scenario
- Failure root causes identified
- BuildConfigs fixed and re-tested
- Success criteria verified
- Build events and descriptions documented
- Internals explanation completed
