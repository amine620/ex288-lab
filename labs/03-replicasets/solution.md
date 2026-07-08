# Solution 03: ReplicaSets

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-alpha-rs
oc project team-alpha-rs
```

## 2) Create ReplicaSet

Create file `rs-app.yaml`:

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-app
  labels:
    app: rs-app
    mission: replicasets
spec:
  replicas: 2
  selector:
    matchLabels:
      app: rs-app
      tier: backend
  template:
    metadata:
      labels:
        app: rs-app
        tier: backend
        env: lab
    spec:
      containers:
        - name: pause
          image: registry.k8s.io/pause:3.9
```

Apply and verify:

```bash
oc apply -f rs-app.yaml
oc get rs
oc get pods -l app=rs-app -o wide
```

## 3) Scale Operations

Scale up:

```bash
oc scale rs/rs-app --replicas=4
oc get rs rs-app
oc get pods -l app=rs-app
```

Scale down:

```bash
oc scale rs/rs-app --replicas=2
oc get pods -l app=rs-app
```

## 4) Break Intentionally

Delete one managed Pod and observe reconciliation:

```bash
oc get pods -l app=rs-app
oc delete pod <one-pod-name>
oc get pods -l app=rs-app -w
```

Intentional selector/template mismatch example:

```bash
oc edit rs rs-app
```

In editor, change Pod template label `tier: backend` to `tier: broken` while selector stays `tier: backend`, save, then inspect:

```bash
oc describe rs rs-app
oc get pods --show-labels
oc get events --sort-by=.lastTimestamp
```

## 5) Troubleshoot and Recover

Fix label alignment:

```bash
oc edit rs rs-app
```

Restore template label to `tier: backend`, then verify:

```bash
oc get rs rs-app
oc get pods -l app=rs-app,tier=backend
```

## 6) Verification Steps

```bash
oc get rs rs-app -o wide
oc describe rs rs-app
oc get pods -l app=rs-app -o custom-columns=NAME:.metadata.name,OWNER:.metadata.ownerReferences[0].kind,READY:.status.containerStatuses[0].ready
```

Expected final state:

- ReplicaSet desired and current replicas match.
- Managed Pods are running and owned by ReplicaSet.
- Reconciliation evidence exists for deletion and recovery scenarios.

## 7) Troubleshooting Guide

- Validate namespace context: `oc project`
- Confirm selector/template alignment in ReplicaSet spec
- Inspect ownership via `ownerReferences` on Pods
- Use `oc describe rs` and events timeline to diagnose mismatch behavior

## 8) Internals Mapping

- API Server validates ReplicaSet updates and stores state in etcd.
- ReplicaSet controller watches desired vs actual Pod count.
- On drift, controller creates or removes Pods to converge state.
- Scheduler assigns new Pods to node(s); kubelet starts containers.
- Status and events feed back into API for ongoing reconciliation visibility.
