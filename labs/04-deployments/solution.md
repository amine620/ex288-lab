# Solution 04: Deployments

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-alpha-deploy
oc project team-alpha-deploy
```

## 2) Create Deployment

Create file `deploy-app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deploy
  labels:
    app: api-deploy
spec:
  replicas: 2
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: api-deploy
  template:
    metadata:
      labels:
        app: api-deploy
        env: lab
    spec:
      containers:
        - name: app
          image: registry.access.redhat.com/ubi9/ubi-minimal
          command: ["/bin/sh", "-c", "echo deployment-ok; sleep 3600"]
```

Apply and verify:

```bash
oc apply -f deploy-app.yaml
oc get deploy
oc get rs
oc get pods -l app=api-deploy
```

## 3) Perform Rolling Update

```bash
oc set image deployment/api-deploy app=registry.k8s.io/pause:3.9
oc rollout status deployment/api-deploy
oc rollout history deployment/api-deploy
oc get rs
```

## 4) Break Rollout Intentionally

```bash
oc set image deployment/api-deploy app=registry.access.redhat.com/ubi9/ubi-minimal:badtag
oc rollout status deployment/api-deploy
oc describe deploy api-deploy
oc get events --sort-by=.lastTimestamp
```

## 5) Troubleshoot and Rollback

```bash
oc rollout history deployment/api-deploy
oc rollout undo deployment/api-deploy
oc rollout status deployment/api-deploy
oc get pods -l app=api-deploy
```

## 6) Verification Steps

```bash
oc get deploy api-deploy -o wide
oc get rs -l app=api-deploy
oc describe deploy api-deploy
oc get pods -l app=api-deploy -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[0].ready,OWNER:.metadata.ownerReferences[0].kind
```

Expected final state:

- Deployment has desired replicas available.
- Latest healthy ReplicaSet is active.
- Failed rollout revision exists in history but not serving traffic.
- Rollback returns workload to healthy image/config.

## 7) Troubleshooting Guide

- Wrong namespace context: `oc project` then switch to `team-alpha-deploy`
- Failed image pull: inspect `oc describe pod` and deployment events
- Identify active revision: `oc rollout history deployment/api-deploy` and compare ReplicaSet pod counts
- Recovery: `oc rollout undo deployment/api-deploy`

## 8) Internals Mapping

- API Server validates deployment changes and stores revisions in etcd.
- Deployment controller creates/scales ReplicaSets based on strategy.
- ReplicaSet controller reconciles Pod count for each revision.
- Scheduler assigns new Pods; kubelet starts and monitors containers.
- Reconciliation loops continue until Deployment desired state is satisfied.
