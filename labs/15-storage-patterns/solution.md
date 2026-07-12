# Solution 15: Storage Patterns

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-storage-patterns
oc project team-storage-patterns
```

## 2) Stateless Pattern (Ephemeral Storage with Deployment)

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache-api
  namespace: team-storage-patterns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cache-api
  template:
    metadata:
      labels:
        app: cache-api
    spec:
      containers:
      - name: app
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              date >> /cache/cache.log
              sleep 5
            done
        volumeMounts:
        - name: cache
          mountPath: /cache
      volumes:
      - name: cache
        emptyDir: {}
EOF

oc rollout status deployment/cache-api
```

## 3) Stateful Pattern (Persistent Storage with StatefulSet)

```bash
oc apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: orders-headless
  namespace: team-storage-patterns
spec:
  clusterIP: None
  selector:
    app: orders-db
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: orders-db
  namespace: team-storage-patterns
spec:
  serviceName: orders-headless
  replicas: 1
  selector:
    matchLabels:
      app: orders-db
  template:
    metadata:
      labels:
        app: orders-db
    spec:
      containers:
      - name: app
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              if [ -f /data/orders.txt ]; then
                tail -n 1 /data/orders.txt >/dev/null 2>&1 || true
              fi
              sleep 5
            done
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
EOF

oc rollout status statefulset/orders-db
oc get pvc
```

## 4) Validate Ephemeral vs Persistent Behavior

```bash
CACHE_POD=$(oc get pod -l app=cache-api -o jsonpath='{.items[0].metadata.name}')
DB_POD=$(oc get pod -l app=orders-db -o jsonpath='{.items[0].metadata.name}')

oc exec "$CACHE_POD" -- sh -c 'echo "temp-data" > /cache/test.txt'
oc exec "$DB_POD" -- sh -c 'echo "order-1" > /data/orders.txt'

oc delete pod "$CACHE_POD" "$DB_POD"
oc rollout status deployment/cache-api
oc rollout status statefulset/orders-db

NEW_CACHE_POD=$(oc get pod -l app=cache-api -o jsonpath='{.items[0].metadata.name}')
NEW_DB_POD=$(oc get pod -l app=orders-db -o jsonpath='{.items[0].metadata.name}')

oc exec "$NEW_CACHE_POD" -- sh -c 'cat /cache/test.txt || true'
oc exec "$NEW_DB_POD" -- sh -c 'cat /data/orders.txt || true'
```

Expected:
- `cache-api` data under `/cache` is lost after pod replacement.
- `orders-db` data under `/data` persists after pod replacement.

## 5) Break Scenario A: Invalid StorageClass in StatefulSet Claim Template

```bash
oc patch statefulset orders-db --type='merge' -p '{"spec":{"volumeClaimTemplates":[{"metadata":{"name":"data"},"spec":{"storageClassName":"does-not-exist","accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1Gi"}}}}]}}'
oc delete pod orders-db-0
oc get pvc
oc describe pvc data-orders-db-0
oc get events --sort-by='.lastTimestamp' | tail -n 20
```

Expected:
- New claim remains `Pending` with provisioning errors.

## 6) Fix Scenario A

```bash
oc patch statefulset orders-db --type='json' -p='[{"op":"remove","path":"/spec/volumeClaimTemplates/0/spec/storageClassName"}]'
oc delete pvc data-orders-db-0
oc delete pod orders-db-0
oc get pvc -w
```

## 7) Break Scenario B: Wrong Data Path (False Persistence)

```bash
DB_POD=$(oc get pod -l app=orders-db -o jsonpath='{.items[0].metadata.name}')
oc exec "$DB_POD" -- sh -c 'echo "wrong-path" > /tmp/orders.txt'
oc delete pod "$DB_POD"
oc rollout status statefulset/orders-db
DB_POD_NEW=$(oc get pod -l app=orders-db -o jsonpath='{.items[0].metadata.name}')
oc exec "$DB_POD_NEW" -- sh -c 'cat /tmp/orders.txt || true'
```

Expected:
- Data under `/tmp` is not reliable for persistence verification.
- Pod may be healthy, but persistence requirement fails.

## 8) Fix Scenario B and Re-verify Correct Path

```bash
oc exec "$DB_POD_NEW" -- sh -c 'echo "order-2" >> /data/orders.txt'
oc delete pod "$DB_POD_NEW"
oc rollout status statefulset/orders-db
DB_POD_FINAL=$(oc get pod -l app=orders-db -o jsonpath='{.items[0].metadata.name}')
oc exec "$DB_POD_FINAL" -- sh -c 'cat /data/orders.txt'
```

## 9) Verification Commands

```bash
oc get deployment,statefulset,pod,pvc,pv
oc describe statefulset orders-db
oc describe pvc data-orders-db-0
oc describe pod $(oc get pod -l app=orders-db -o jsonpath='{.items[0].metadata.name}')
oc get events --sort-by='.lastTimestamp' | tail -n 30
```

## 10) Troubleshooting Quick Reference

- PVC Pending:
  - `oc get pvc`
  - `oc describe pvc <name>`
  - `oc get sc`
- StatefulSet storage errors:
  - `oc describe statefulset <name>`
  - `oc describe pod <pod>`
  - inspect `volumeClaimTemplates` and generated claim names
- False persistence checks:
  - confirm write path is under mounted PVC path
  - verify mount paths with `oc exec <pod> -- mount | grep data`

## 11) Internal Explanation Checklist

When writing your explanation, include:
- API Server persists Deployment/StatefulSet/PVC desired state in etcd.
- StatefulSet controller preserves identity and manages ordered pod reconciliation.
- PVC/PV controller provisions and binds storage for claim templates.
- Scheduler places pods on nodes; kubelet mounts volumes before container start.
- Events and status conditions reveal each reconcile step and failure point.