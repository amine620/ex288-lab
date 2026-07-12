# Notes 10: Build Troubleshooting

## Mission Focus

Build troubleshooting requires understanding how builds fail, where error messages appear, and how to access them before they're lost.

## OpenShift Layer

### BuildConfig

- Declarative build configuration; errors stored at creation time if YAML is invalid.
- Git URI, strategy, output target—all validated when build is triggered.

### Build Object

- Represents a specific build run; status includes phase (Pending, Running, Complete, Failed, Error).
- Failure reason stored in Build.status.reason and message.

### Build Pod

- Executes the build (runs builder image, clones Git, runs assemble, pushes image).
- Logs accessible via `oc logs` until pod is deleted.
- Pod lifecycle: Pending → Running → Succeeded/Failed.

## Kubernetes Layer

### Build Pod Logs

- Pod stdout/stderr captured by kubelet and stored locally on node.
- Accessible via `oc logs` (queries kubelet API).
- Lost when pod is deleted (unless captured separately).

### Pod Status

- Pod.status.phase shows current state.
- Pod.status.conditions show detailed transitions.
- ImagePullBackOff indicates builder image cannot be pulled.
- CrashLoopBackOff indicates pod crashed on startup (rare for builds).

### ServiceAccount

- Attached to build pod; grants access to pull source images and push to registry.
- ImagePullSecrets and registry credentials come from ServiceAccount.

## Build Failure Taxonomy

### 1. Clone Failure (Git)

**When**: At start of build, during Git clone.
**Cause**: Invalid URI, network issue, missing SSH key, bad branch ref.
**Where**: Visible in build pod logs early (first 100 lines).
**Error**: "fatal: unable to access 'https://...'", "Host key verification failed".

### 2. Assemble Failure (S2I)

**When**: During build strategy execution (after clone).
**Cause**: Missing assemble script, script error, missing dependencies, interpreter error.
**Where**: Build pod logs show assemble script execution and errors.
**Error**: "assemble: command not found", "Python: No module named...", script exit code != 0.

### 3. Push Failure (Registry)

**When**: After image is built, during push to internal registry.
**Cause**: Missing credentials, wrong output target format, registry unreachable.
**Where**: Near end of build pod logs.
**Error**: "denied: access forbidden", "no basic auth credentials", "connection refused".

### 4. Resource Quota Exceeded

**When**: Build pod cannot start due to project limits.
**Cause**: Project CPU/memory limits reached.
**Where**: Pod remains Pending; describe pod shows "quota exceeded".
**Error**: "Pod <name> failed to start: Insufficient <cpu/memory>".

### 5. Image Pull Failure

**When**: At pod startup, when pulling builder image.
**Cause**: ImageStream tag not found, builder image cannot be pulled from external registry.
**Where**: Pod stuck in ImagePullBackOff.
**Error**: Pod describe shows "Failed to pull image...", "not found".

## Troubleshooting Workflow

```
1. Check Build status
   oc get build <name>
   oc describe build <name>

2. Access Build Pod logs (if pod still exists)
   oc logs <pod-name>
   oc logs <pod-name> --timestamps
   oc logs <pod-name> --tail=50

3. Check Build object persistence (logs survive pod deletion)
   oc logs build/<build-name>

4. Inspect Build Pod spec and status
   oc describe pod <pod-name>
   oc get pod <pod-name> -o yaml

5. Correlate with Events
   oc get events --field-selector involvedObject.kind=Build

6. Fix BuildConfig and re-trigger
   oc patch bc <name> -p '{"spec":{...}}'
   oc start-build <bc-name> --follow
```

## Relationship Summary

- **BuildConfig** → declarative template.
- **Build** → specific build run; status (phase, reason) persisted in etcd.
- **Build Pod** → executes build; logs available via kubelet.
- **BuildConfig Controller** → watches for trigger conditions, creates Build.
- **Build Controller** → watches Build object, creates Pod, captures logs.
- **Logs** → stored in etcd (via Build object) and on node (via kubelet).

## Log Access Patterns

| Scenario                    | Command                   | Persistence            |
| --------------------------- | ------------------------- | ---------------------- |
| Build running               | `oc logs -f build/<name>` | Real-time from kubelet |
| Build complete, pod exists  | `oc logs build/<name>`    | Kubelet local storage  |
| Build complete, pod deleted | `oc logs build/<name>`    | etcd (Build object)    |
| Pod logs after pod GC       | Not available             | Lost when pod deleted  |

## EX288 Relevance

- Build troubleshooting is critical for CI/CD scenarios on exam.
- Ability to diagnose failures quickly using logs and events separates passing from failing scores.
- Understanding build pod lifecycle explains how errors propagate to Build objects.
- Practice with intentional failures builds confidence for real production issues.
