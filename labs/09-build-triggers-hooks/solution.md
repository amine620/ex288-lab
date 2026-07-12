# Solution 09: Build Triggers and Hooks

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-alpha-triggers
oc project team-alpha-triggers
```

## 2) Create Base ImageStream (for ImageChange Trigger)

```yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: python-base
  namespace: team-alpha-triggers
spec:
  lookupPolicy:
    local: false
```

```bash
oc apply -f - <<EOF
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: python-base
  namespace: team-alpha-triggers
spec:
  lookupPolicy:
    local: false
---
apiVersion: image.openshift.io/v1
kind: ImageStreamTag
metadata:
  name: python-base:3.11
  namespace: team-alpha-triggers
spec:
  from:
    kind: DockerImage
    name: registry.access.redhat.com/ubi9/python-311
  importPolicy:
    scheduled: true
EOF
```

## 3) Create Pre-Build and Post-Build Hook Scripts

Create file `pre-build-hook.sh`:

```bash
#!/bin/bash
echo "=== PRE-BUILD HOOK EXECUTION ==="
echo "Validating build parameters..."
if [ -z "$APP_VERSION" ]; then
  echo "ERROR: APP_VERSION not set"
  exit 1
fi
echo "Pre-build validation passed. APP_VERSION=$APP_VERSION"
exit 0
```

Create file `post-build-hook.sh`:

```bash
#!/bin/bash
echo "=== POST-BUILD HOOK EXECUTION ==="
echo "Build completed. Performing post-build tasks..."
echo "Image pushed to registry. Running integration checks..."
echo "Post-build hook completed successfully."
exit 0
```

## 4) Create BuildConfig with Triggers and Hooks

Create file `buildconfig-triggers.yaml`:

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: app-with-triggers
  namespace: team-alpha-triggers
  labels:
    app: app-with-triggers
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
      name: app-with-triggers:latest

  # Pre-build hook
  postCommit:
    command: ["/bin/bash", "-c"]
    args: ["echo 'POST-BUILD HOOK'; env | grep APP_VERSION"]

  # Triggers: automatic build on ConfigChange and ImageChange
  triggers:
    - type: ConfigChange
    - type: ImageChange
      imageChange:
        from:
          kind: ImageStreamTag
          name: python-base:3.11
    - type: GitHub
      github:
        secret: "github-secret-key"

  env:
    - name: APP_VERSION
      value: "1.0.0"
    - name: BUILD_TIMESTAMP
      value: "2026-07-02"
```

```bash
oc apply -f buildconfig-triggers.yaml
oc get bc
oc describe bc app-with-triggers
```

## 5) Verify Triggers Are Configured

```bash
# Check BuildConfig triggers
oc get bc app-with-triggers -o jsonpath='{.spec.triggers}' | jq .

# Check trigger configuration details
oc describe bc app-with-triggers | grep -A5 "Triggers:"
```

## 6) Manually Trigger a Build

```bash
# Trigger build manually
oc start-build app-with-triggers --follow

# Watch for trigger events
oc get events --sort-by=.lastTimestamp | grep -i trigger
oc get events --sort-by=.lastTimestamp | grep -i hook
```

Expected: Build starts, logs show post-build hook execution.

## 7) Trigger ConfigChange (Modify BuildConfig)

```bash
# Edit BuildConfig to trigger ConfigChange trigger
oc patch bc app-with-triggers -p '{"spec":{"env":[{"name":"APP_VERSION","value":"1.0.1"}]}}'

# Verify new build was automatically triggered
oc get builds
oc get events --sort-by=.lastTimestamp | grep -i configchange
```

Expected: New Build object created automatically due to ConfigChange trigger.

## 8) Trigger ImageChange (Update Base Image)

```bash
# Simulate ImageStream tag update to trigger ImageChange
oc patch imagestream python-base -p '{"spec":{"tags":[{"name":"3.11","from":{"kind":"DockerImage","name":"registry.access.redhat.com/ubi9/python-311:latest"}}]}}'

# Verify new build was automatically triggered
oc get builds
oc get events --sort-by=.lastTimestamp | grep -i imagechange
```

Expected: New Build object created automatically due to ImageChange trigger.

## 9) Check Build Pod and Hook Execution

```bash
# List all builds
oc get builds

# Get logs from specific build (shows hook output)
BUILD_NAME=$(oc get builds -o name | head -1)
oc logs $BUILD_NAME

# Alternatively, follow build with hook output
oc start-build app-with-triggers --follow --wait

# Check if hook executed successfully
oc describe build $(oc get build -o name | head -1)
```

Expected output: Build logs include post-build hook execution message.

## 10) Trigger Pre-Build Hook Failure Scenario

Modify BuildConfig to have a failing pre-build hook:

```bash
oc patch bc app-with-triggers -p '{"spec":{"postCommit":{"command":["/bin/sh","-c"],"args":["exit 1"]}}}'

# Trigger a build
oc start-build app-with-triggers --follow

# Check logs to see hook failure
oc logs $(oc get builds -o name | head -1) | tail -20
```

Expected: Build logs show hook failed with exit code 1.

## 11) Verify Trigger Webhook Configuration

```bash
# Get GitHub webhook secret
oc get bc app-with-triggers -o jsonpath='{.spec.triggers[?(@.type=="GitHub")].github.secret}'

# Get webhook URL (for external configuration)
oc describe bc app-with-triggers | grep -i webhook

# Simulate webhook call (if available)
# curl -X POST <webhook-url>
```

## 12) Monitor Build Events and Status

```bash
# Get all events for this build
oc get events --field-selector involvedObject.kind=Build --sort-by=.lastTimestamp

# Watch for new builds in real-time
oc get builds -w

# Check build controller logs for trigger evaluation
# (typically in openshift-build namespace)
```

## 13) Verification Steps

```bash
# Final state: BuildConfig with active triggers
oc get bc app-with-triggers -o wide

# List all builds triggered by this config
oc get builds -l buildconfig=app-with-triggers

# Check if any builds failed due to hook issues
oc get builds -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,REASON:.status.reason

# Verify ImageStream tracking
oc get is app-with-triggers
```

## 14) Cleanup

```bash
oc delete project team-alpha-triggers
```
