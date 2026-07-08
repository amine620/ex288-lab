# Solution 08: Binary Builds

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-alpha-binary
oc project team-alpha-binary
```

## 2) Create a Simple Binary Artifact (Go or Shell)

### Option A: Go Binary (preferred for exam context)

Create file `main.go`:

```go
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Binary build successful!\n")
    })
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        fmt.Fprintf(w, "OK\n")
    })
    fmt.Println("Server starting on :8080")
    http.ListenAndServe(":8080", nil)
}
```

Build the binary:

```bash
# On your host machine
go build -o app main.go
ls -lh app
```

### Option B: Compiled Shell Script (simpler)

Create file `app.sh`:

```bash
#!/bin/bash
while true; do
  echo "Binary artifact running..."
  sleep 10
done
```

```bash
chmod +x app.sh
```

## 3) Create Dockerfile for Binary Build

Create file `Dockerfile`:

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal
COPY app /usr/local/bin/app
RUN chmod +x /usr/local/bin/app
EXPOSE 8080
CMD ["/usr/local/bin/app"]
```

## 4) Create Build Context Directory

```bash
mkdir -p build-context
cp app build-context/
cp Dockerfile build-context/
cd build-context
tar czf ../binary-artifact.tar.gz .
cd ..
ls -lh binary-artifact.tar.gz
```

## 5) Create ImageStream

Create file `imagestream.yaml`:

```yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  name: binary-app
  namespace: team-alpha-binary
spec:
  lookupPolicy:
    local: false
```

```bash
oc apply -f imagestream.yaml
oc get is
```

## 6) Create Binary BuildConfig

Create file `buildconfig-binary.yaml`:

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: binary-app
  namespace: team-alpha-binary
spec:
  source:
    type: Binary
    binary: {}
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile
      from:
        kind: ImageStreamTag
        name: "ubi-minimal:latest"
        namespace: openshift
  output:
    to:
      kind: ImageStreamTag
      name: "binary-app:latest"
  triggers:
    - type: ConfigChange
```

```bash
oc apply -f buildconfig-binary.yaml
oc get bc
oc describe bc binary-app
```

## 7) Upload Binary Artifact and Trigger Build

```bash
# Start build with binary artifact
oc start-build binary-app --from-file=binary-artifact.tar.gz --follow

# Alternative: from directory
# oc start-build binary-app --from-dir=build-context --follow
```

Monitor build:

```bash
# Check build status
oc get builds
oc describe build binary-app-1
oc logs build/binary-app-1

# Wait for build to complete
oc get builds -w
```

Expected output: Build completes, image is pushed to internal registry.

## 8) Verify ImageStream and Image

```bash
# Check ImageStream
oc get is binary-app
oc describe is binary-app

# Extract image digest
IMAGE_DIGEST=$(oc get is binary-app -o jsonpath='{.status.tags[0].items[0].image}')
echo "Image digest: $IMAGE_DIGEST"
```

## 9) Create Deployment Using Binary-Built Image

Create file `deployment-binary.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: binary-app
  namespace: team-alpha-binary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: binary-app
  template:
    metadata:
      labels:
        app: binary-app
    spec:
      containers:
        - name: app
          image: image-registry.openshift-image-registry.svc:5000/team-alpha-binary/binary-app:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "50m"
              memory: "64Mi"
            limits:
              cpu: "200m"
              memory: "128Mi"
```

```bash
oc apply -f deployment-binary.yaml
oc rollout status deployment/binary-app
oc get pods -l app=binary-app -o wide
```

## 10) Verify Deployment is Running

```bash
# Check pod status
oc get pods -l app=binary-app
oc logs -l app=binary-app
oc describe pod -l app=binary-app
```

Expected: Pod is Running, image pulled from internal registry successfully.

## 11) Troubleshooting: Build Failures

### Scenario A: Artifact Missing

```bash
# Try to build with missing artifact
oc start-build binary-app --from-file=nonexistent.tar.gz 2>&1

# Check build logs for error
oc logs build/binary-app-2
```

Expected: Build fails immediately with file not found error.

### Scenario B: Dockerfile Invalid

Edit BuildConfig to reference missing file:

```bash
oc edit bc binary-app
# Change dockerfilePath to: Dockerfile-notfound
```

```bash
oc start-build binary-app --from-dir=build-context --follow
# Watch build fail during Docker step
oc logs build/binary-app-3
```

Expected: Build fails at Docker build step.

### Scenario C: Registry Push Failure

Check build pod's service account permissions:

```bash
oc get sa builder -o yaml
oc get rolebinding -n team-alpha-binary | grep builder
```

Verify registry is accessible:

```bash
# From build pod
oc rsh -c app pod/binary-app-xxxxx
curl -v http://image-registry.openshift-image-registry.svc:5000/v2/
```

## 12) Verification Steps

```bash
# Final build status
oc get builds
oc describe build binary-app-1

# Image in registry
oc get is binary-app -o jsonpath='{.status.tags[0].items[0].image}'

# Deployment status
oc get deploy binary-app -o wide
oc get pods -l app=binary-app

# Events showing build and image push
oc get events --sort-by=.lastTimestamp
```

## 13) Cleanup

```bash
oc delete project team-alpha-binary
```
