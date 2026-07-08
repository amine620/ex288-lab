# Solution 02: Pods

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-alpha-pods
oc project team-alpha-pods
```

## 2) Create Standalone Pods

### Long-running diagnostics Pod

```bash
oc run diag-pod \
  --image=registry.k8s.io/pause:3.9 \
  --labels=app=diag,role=diagnostics,env=lab
```

### Command-focused Pod

```bash
oc run check-pod \
  --image=registry.access.redhat.com/ubi9/ubi-minimal \
  --labels=app=check,role=command-check,env=lab \
  --command -- /bin/sh -c 'echo pod-check-ok; sleep 300'
```

## 3) Modify Pod Metadata and Behavior

```bash
oc annotate pod diag-pod purpose=pod-lifecycle-practice --overwrite
```

Pod command updates require recreation:

```bash
oc delete pod check-pod
oc run check-pod \
  --image=registry.access.redhat.com/ubi9/ubi-minimal \
  --labels=app=check,role=command-check,env=lab \
  --command -- /bin/sh -c 'echo recreated-check; sleep 300'
```

## 4) Break Intentionally

```bash
oc run broken-pod \
  --image=registry.access.redhat.com/ubi9/ubi-minimal:badtag \
  --labels=app=broken,role=troubleshoot,env=lab
```

Inspect failure:

```bash
oc get pod broken-pod -w
oc describe pod broken-pod
oc get events --sort-by=.lastTimestamp
```

## 5) Troubleshoot and Recover

```bash
oc delete pod broken-pod
oc run broken-pod \
  --image=registry.access.redhat.com/ubi9/ubi-minimal \
  --labels=app=broken,role=troubleshoot,env=lab \
  --command -- /bin/sh -c 'echo recovered; sleep 300'
```

## 6) Verification Steps

```bash
oc get pods -o wide
oc get pods -L role,env
oc logs check-pod
oc describe pod diag-pod
```

Expected final state:

- `diag-pod` is Running.
- `check-pod` is Running and log output contains recreated command text.
- `broken-pod` is Running after recreation with valid image.

## 7) YAML Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: diag-pod-yaml
  namespace: team-alpha-pods
  labels:
    app: diag
    role: diagnostics
    env: lab
  annotations:
    purpose: yaml-created
spec:
  containers:
    - name: pause
      image: registry.k8s.io/pause:3.9
```

Apply:

```bash
oc apply -f pod-diag.yaml
oc get pod diag-pod-yaml
```

## 8) Troubleshooting Steps Reference

- Validate active namespace: `oc project`
- Search across namespaces when unsure: `oc get pod -A`
- Inspect event timeline: `oc get events --sort-by=.lastTimestamp`
- Use `oc describe pod <name>` to identify failure reason
- Recreate standalone Pod for immutable-field changes or wrong image

## 9) Internals Mapping

- API Server validates and persists Pod specs in etcd.
- Scheduler binds unscheduled Pods to the CRC node.
- Kubelet pulls images and starts containers.
- Status updates return through API Server to etcd.
- Controllers/watchers observe changes and keep system state converging.
