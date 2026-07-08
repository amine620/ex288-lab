# Solution 01: Projects and Namespaces

## 1) Create Projects (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443

oc new-project team-alpha-dev
oc new-project team-alpha-test
```

## 2) Add Namespace Metadata

```bash
oc label namespace team-alpha-dev team=alpha env=dev --overwrite
oc annotate namespace team-alpha-dev owner=platform-alpha purpose=development --overwrite

oc label namespace team-alpha-test team=alpha env=test --overwrite
oc annotate namespace team-alpha-test owner=platform-alpha purpose=testing --overwrite
```

## 3) Deploy Minimal Workloads

### Create a deployment in dev

```bash
oc -n team-alpha-dev create deployment web-dev --image=registry.k8s.io/pause:3.9
oc -n team-alpha-dev scale deployment/web-dev --replicas=1
```

### Intentionally break: deploy test workload to wrong namespace

```bash
oc -n team-alpha-dev create deployment web-test --image=registry.k8s.io/pause:3.9
```

## 4) Troubleshoot and Fix

### Symptom: `web-test` not found in test project

```bash
oc project team-alpha-test
oc get deploy
```

Expected: `web-test` is missing.

### Find misplaced resource

```bash
oc get deploy -A | findstr web-test
```

Expected: deployment appears in `team-alpha-dev`.

### Corrective action

```bash
oc -n team-alpha-dev delete deployment web-test
oc -n team-alpha-test create deployment web-test --image=registry.k8s.io/pause:3.9
```

## 5) Verification Steps

```bash
oc get project team-alpha-dev team-alpha-test
oc get ns team-alpha-dev team-alpha-test --show-labels
oc -n team-alpha-dev get deploy,pod
oc -n team-alpha-test get deploy,pod
```

Expected final state:

- `web-dev` only in `team-alpha-dev`
- `web-test` only in `team-alpha-test`
- Labels and annotations present on both namespaces

## 6) Optional YAML Variant

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: team-alpha-dev
  labels:
    team: alpha
    env: dev
  annotations:
    owner: platform-alpha
    purpose: development
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-dev
  namespace: team-alpha-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-dev
  template:
    metadata:
      labels:
        app: web-dev
    spec:
      containers:
        - name: pause
          image: registry.k8s.io/pause:3.9
```

Apply with:

```bash
oc apply -f namespace-and-deployment.yaml
```

## 7) Troubleshooting Guide

### Issue: Wrong active project context

- Check current project: `oc project`
- Switch project: `oc project team-alpha-test`

### Issue: Resource appears missing

- Search all namespaces: `oc get deploy -A`
- Confirm namespace-qualified query: `oc -n <namespace> get deploy`

### Issue: Label-based filtering returns unexpected results

- Inspect actual labels: `oc get ns --show-labels`
- Fix labels with `oc label namespace ... --overwrite`

## 8) Internals Mapping

- API Server validates each request and writes objects to etcd.
- Namespace and Deployment controllers watch API changes and reconcile desired state.
- Scheduler binds Pods for new ReplicaSets created by Deployment controller.
- Reconciliation continues until observed state matches declared state.
