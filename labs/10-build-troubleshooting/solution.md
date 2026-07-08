# Solution 10: Build Troubleshooting

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-troubleshoot-builds
oc project team-troubleshoot-builds
```

## 2) Create Base ImageStream

```bash
oc apply -f - <<EOF
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: python-base
  namespace: team-troubleshoot-builds
spec:
  lookupPolicy:
    local: false
---
apiVersion: image.openshift.io/v1
kind: ImageStreamTag
metadata:
  name: python-base:3.11
  namespace: team-troubleshoot-builds
spec:
  from:
    kind: DockerImage
    name: registry.access.redhat.com/ubi9/python-311
  importPolicy:
    scheduled: true
EOF
```

## 3) Scenario A: Git Clone Failure

Create BuildConfig with invalid Git URI:

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: build-git-failure
  namespace: team-troubleshoot-builds
spec:
  source:
    type: Git
    git:
      uri: https://github.com/this-repo-does-not-exist-12345.git
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: python-base:3.11
  output:
    to:
      kind: ImageStreamTag
      name: app-git-failure:latest
```

```bash
oc apply -f - <<EOF
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: build-git-failure
  namespace: team-troubleshoot-builds
spec:
  source:
    type: Git
    git:
      uri: https://github.com/this-repo-does-not-exist-12345.git
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: python-base:3.11
  output:
    to:
      kind: ImageStreamTag
      name: app-git-failure:latest
EOF

# Trigger the build
oc start-build build-git-failure --follow
```

Expected: Build fails with "fatal: unable to access" error in logs.

### Diagnosis:

```bash
# Get logs from failed build
oc logs build/build-git-failure-1

# Describe the Build to see failure reason
oc describe build build-git-failure-1

# Check events
oc get events --field-selector involvedObject.kind=Build --sort-by='.lastTimestamp'
```

Output will show Git clone failure message.

## 4) Scenario B: S2I Assemble Failure

Create a BuildConfig pointing to a repo without proper S2I structure:

```bash
oc apply -f - <<EOF
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: build-assemble-failure
  namespace: team-troubleshoot-builds
spec:
  source:
    type: Git
    git:
      uri: https://github.com/openshift/nodejs-ex.git
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: python-base:3.11
      # This mismatch will cause assemble failure
  output:
    to:
      kind: ImageStreamTag
      name: app-assemble-failure:latest
EOF

# Trigger build
oc start-build build-assemble-failure --follow
```

Expected: Build fails during S2I assemble step with incompatibility errors.

### Diagnosis:

```bash
# Get full build logs (may be large)
oc logs build/build-assemble-failure-1 --timestamps

# Tail build logs in real-time while building
oc start-build build-assemble-failure --follow

# Check if assemble script is missing
oc logs build/build-assemble-failure-1 | grep -i assemble
```

## 5) Scenario C: Registry Push Failure (No Credentials)

Create BuildConfig but intentionally miss ServiceAccount setup:

```bash
oc apply -f - <<EOF
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: build-push-failure
  namespace: team-troubleshoot-builds
spec:
  source:
    type: Git
    git:
      uri: https://github.com/openshift/nodejs-ex.git
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: python-base:3.11
  output:
    to:
      kind: ImageStreamTag
      name: app-push-failure:latest
  serviceAccount: non-existent-sa
EOF

# Trigger build
oc start-build build-push-failure --follow
```

Expected: Build fails during push due to missing ServiceAccount/credentials.

### Diagnosis:

```bash
# Check ServiceAccount existence
oc get sa

# Check builder ServiceAccount docker-cfg secret
oc get sa builder -o yaml
oc get secret $(oc get sa builder -o jsonpath='{.secrets[0].name}')

# Check build logs for push error
oc logs build/build-push-failure-1 | grep -i "push\|denied\|auth"

# Describe build for failure reason
oc describe build build-push-failure-1
```

## 6) Scenario D: Successful Build (Baseline)

Create a working BuildConfig:

```bash
oc apply -f - <<EOF
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: build-success
  namespace: team-troubleshoot-builds
spec:
  source:
    type: Git
    git:
      uri: https://github.com/openshift/nodejs-ex.git
      ref: main
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: python-base:3.11
  output:
    to:
      kind: ImageStreamTag
      name: app-success:latest
EOF

# Trigger and follow build
oc start-build build-success --follow
```

Expected: Build succeeds and image is pushed to ImageStream.

### Diagnosis:

```bash
# Check successful build logs
oc logs build/build-success-1

# Verify image was pushed
oc get is app-success
oc describe is app-success
```

## 7) Access Build Pod Logs Before Cleanup

Build pods are garbage-collected after completion. To preserve logs:

```bash
# Get logs immediately after build fails
BUILD_POD=$(oc get pod -l build=build-git-failure-1 -o name | head -1)
oc logs $BUILD_POD > build-git-failure-logs.txt

# Get all logs including previous (if pod restarted)
oc logs $BUILD_POD --previous

# Get logs from completed build object (persisted in etcd)
oc logs build/build-git-failure-1
```

## 8) Common Failure Patterns and Resolution

### Pattern: No Route to Push Registry

```bash
# Check internal registry service
oc get svc -n openshift-image-registry

# If build cannot reach registry, check network policy
oc get networkpolicy -n team-troubleshoot-builds

# Verify BuildConfig output target format
oc get bc build-success -o jsonpath='{.spec.output}'
```

### Pattern: Build Pod in ImagePullBackOff

```bash
# Check if builder image can be pulled
oc describe pod $(oc get pod -l build=build-success-1 -o name)

# Verify ImageStream tag exists
oc get is python-base -o yaml
```

### Pattern: Build Hangs or Times Out

```bash
# Check build progress
oc get build build-success-1 -w

# Check pod status
oc get pod -l build=build-success-1 -o wide

# Manually cancel stuck build
oc cancel-build build-success-1
```

## 9) Monitor Build Events

```bash
# Watch all build-related events
oc get events --field-selector involvedObject.kind=Build --watch

# Get events for specific build
oc describe build build-success-1 | grep -A20 "Events:"

# Check BuildConfig-level events
oc get events --field-selector involvedObject.name=build-success
```

## 10) Archive Build Logs for Analysis

```bash
# Save all build logs
for BUILD in $(oc get builds -o name); do
  oc logs $BUILD > $(echo $BUILD | sed 's|build/||').log
done

# Create summary
oc get builds -o wide > builds-summary.txt
oc get events > all-events.txt
```

## 11) Fix and Re-test Scenario A

```bash
# Correct the Git URI
oc patch bc build-git-failure -p '{"spec":{"source":{"git":{"uri":"https://github.com/openshift/nodejs-ex.git"}}}}'

# Re-trigger build
oc start-build build-git-failure --follow

# Verify success
oc logs build/build-git-failure-2 | tail -20
```

## 12) Verification Steps

```bash
# Final state: Check all builds
oc get builds -o wide

# Verify successful builds have images
oc get imagestreams

# Check that failed builds show error reasons
oc get builds -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,REASON:.status.reason

# Confirm no pods are stuck
oc get pods -l openshift.io/build-config
```

## 13) Advanced: Analyze Build Pod Initialization

```bash
# Examine build pod spec
oc get pod $(oc get pod -l build=build-success-1 -o name) -o yaml

# Check build pod environment variables
oc get pod -l build=build-success-1 -o jsonpath='{.items[0].spec.containers[0].env}' | jq

# Check build pod service account
oc get pod -l build=build-success-1 -o jsonpath='{.items[0].spec.serviceAccountName}'
```

## 14) Cleanup

```bash
oc delete project team-troubleshoot-builds
```
