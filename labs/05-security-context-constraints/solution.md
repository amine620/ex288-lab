# Solution 05: Security Context Constraints (SCC)

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-alpha-scc
oc project team-alpha-scc
oc create sa legacy-sa
```

## 2) Create a Deployment That Intentionally Fails SCC

Create file `legacy-web.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-web
  labels:
    app: legacy-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-web
  template:
    metadata:
      labels:
        app: legacy-web
    spec:
      serviceAccountName: legacy-sa
      containers:
        - name: web
          image: registry.access.redhat.com/ubi9/ubi-minimal
          command: ["/bin/sh", "-c", "echo running as root; sleep 3600"]
          securityContext:
            runAsUser: 0
            allowPrivilegeEscalation: false
```

Apply and inspect:

```bash
oc apply -f legacy-web.yaml
oc get deploy,rs,pods
oc describe rs -l app=legacy-web
oc get events --sort-by=.lastTimestamp
```

Expected failure evidence:

- Pod creation denied by SCC admission.
- Deployment and ReplicaSet exist, but desired Pod is not created successfully.

## 3) Verify Which SCC Is Available to ServiceAccount

```bash
oc auth can-i use scc/restricted-v2 --as system:serviceaccount:team-alpha-scc:legacy-sa
oc auth can-i use scc/anyuid --as system:serviceaccount:team-alpha-scc:legacy-sa
```

## 4) Apply Targeted Least-Privilege Fix

Grant `anyuid` only to `legacy-sa` in this namespace:

```bash
oc adm policy add-scc-to-user anyuid -z legacy-sa -n team-alpha-scc
```

Reconcile and verify:

```bash
oc rollout restart deployment/legacy-web
oc rollout status deployment/legacy-web
oc get pods -l app=legacy-web -o wide
oc describe pod -l app=legacy-web
```

## 5) Verification Steps

```bash
oc get deploy legacy-web -o wide
oc get rs -l app=legacy-web
oc get pod -l app=legacy-web -o custom-columns=NAME:.metadata.name,SA:.spec.serviceAccountName,PHASE:.status.phase
oc auth can-i use scc/anyuid --as system:serviceaccount:team-alpha-scc:legacy-sa
```

Expected final state:

- Deployment has available replicas.
- Pod is created using `legacy-sa`.
- SCC denial no longer appears for this workload.
- SCC grant scope is limited to one ServiceAccount.

## 6) Troubleshooting Guide

- Wrong context: run `oc project` and confirm `team-alpha-scc`.
- Still failing SCC: confirm Deployment uses `serviceAccountName: legacy-sa`.
- Wrong principal granted: inspect SCC users/groups and re-grant correctly.
- Overly broad permissions: remove broad grants and keep SA-scoped binding.

## 7) Optional Cleanup / Rollback of Permission

```bash
oc adm policy remove-scc-from-user anyuid -z legacy-sa -n team-alpha-scc
oc delete project team-alpha-scc
```

## 8) Internals Mapping

- API Server receives PodTemplate updates from Deployment.
- SCC admission plugin evaluates pod security context against allowed SCCs for the ServiceAccount.
- Accepted objects are persisted in etcd; denied pod creations are rejected and surfaced as events.
- Deployment controller and ReplicaSet controller keep reconciling desired state.
- Once SCC access is corrected, reconciliation loops succeed and Pods become Running.
