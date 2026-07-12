# Solution 14: Volumes and PVCs

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-volumes-pvcs
oc project team-volumes-pvcs
```

## 2) Create a PVC (Working Baseline)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: team-volumes-pvcs
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```bash
oc apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: team-volumes-pvcs
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

oc get pvc app-data
oc describe pvc app-data
```

## 3) Deploy Workload with emptyDir + PVC

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storage-demo
  namespace: team-volumes-pvcs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-demo
  template:
    metadata:
      labels:
        app: storage-demo
    spec:
      containers:
      - name: main
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              date >> /cache/cache.log
              sleep 5
            done
        volumeMounts:
        - name: cache-volume
          mountPath: /cache
        - name: data-volume
          mountPath: /data
      volumes:
      - name: cache-volume
        emptyDir: {}
      - name: data-volume
        persistentVolumeClaim:
          claimName: app-data
```

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storage-demo
  namespace: team-volumes-pvcs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-demo
  template:
    metadata:
      labels:
        app: storage-demo
    spec:
      containers:
      - name: main
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              date >> /cache/cache.log
              sleep 5
            done
        volumeMounts:
        - name: cache-volume
          mountPath: /cache
        - name: data-volume
          mountPath: /data
      volumes:
      - name: cache-volume
        emptyDir: {}
      - name: data-volume
        persistentVolumeClaim:
          claimName: app-data
EOF

oc rollout status deployment/storage-demo
```

## 4) Write Test Data to Both Volumes

```bash
POD=$(oc get pod -l app=storage-demo -o jsonpath='{.items[0].metadata.name}')

oc exec "$POD" -- sh -c 'echo "persistent-1" > /data/state.txt'
oc exec "$POD" -- sh -c 'echo "ephemeral-1" > /cache/state.txt'

oc exec "$POD" -- cat /data/state.txt
oc exec "$POD" -- cat /cache/state.txt
```

## 5) Recreate Pod and Compare Data

```bash
oc delete pod "$POD"
oc rollout status deployment/storage-demo

NEW_POD=$(oc get pod -l app=storage-demo -o jsonpath='{.items[0].metadata.name}')

oc exec "$NEW_POD" -- sh -c 'ls -l /data /cache'
oc exec "$NEW_POD" -- sh -c 'cat /data/state.txt || true'
oc exec "$NEW_POD" -- sh -c 'cat /cache/state.txt || true'
```

Expected:
- `/data/state.txt` still exists.
- `/cache/state.txt` is missing after pod replacement.

## 6) Break Scenario A: PVC Pending (Bad StorageClass)

```bash
oc apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-bad-sc
  namespace: team-volumes-pvcs
spec:
  storageClassName: does-not-exist
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

oc get pvc app-data-bad-sc
oc describe pvc app-data-bad-sc
oc get events --sort-by='.lastTimestamp' | tail -n 20
```

Expected:
- PVC remains `Pending`.
- Events mention missing provisioner or StorageClass.

## 7) Fix Scenario A

```bash
oc patch pvc app-data-bad-sc -p '{"spec":{"storageClassName":null}}'
oc get pvc app-data-bad-sc -w
```

If patch is rejected in your cluster version, delete and recreate PVC without `storageClassName`.

## 8) Break Scenario B: Wrong Claim Name in Deployment

```bash
oc patch deployment storage-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/volumes/1/persistentVolumeClaim/claimName","value":"wrong-claim-name"}]'

oc rollout status deployment/storage-demo --timeout=60s || true
oc get pods -l app=storage-demo
oc describe pod $(oc get pod -l app=storage-demo -o jsonpath='{.items[0].metadata.name}')
```

Expected:
- Pod remains Pending/ContainerCreating.
- Events show PVC not found or mount failure.

## 9) Fix Scenario B

```bash
oc patch deployment storage-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/volumes/1/persistentVolumeClaim/claimName","value":"app-data"}]'

oc rollout status deployment/storage-demo
```

## 10) Verification Commands

```bash
oc get deployment,pod,pvc,pv
oc describe pvc app-data
oc describe pod $(oc get pod -l app=storage-demo -o jsonpath='{.items[0].metadata.name}')
oc get events --sort-by='.lastTimestamp' | tail -n 30
```

## 11) Troubleshooting Quick Reference

- PVC stuck Pending:
  - `oc get pvc`
  - `oc describe pvc <name>`
  - `oc get sc`
- Pod cannot mount PVC:
  - `oc describe pod <pod>`
  - `oc get pvc <name>`
  - Verify claim name and namespace
- Data not persistent:
  - Validate `volumeMounts` and `volumes` mapping
  - Confirm writes are under PVC mount path, not `emptyDir`

## 12) Internal Explanation Checklist

When writing your explanation, include:
- API Server persists Deployment/PVC specs to etcd.
- PVC/PV controller binds/provisions storage to satisfy claim.
- Scheduler places Pod; kubelet mounts volumes on node.
- Deployment controller reconciles desired replicas.
- Events and status fields expose each reconciliation step and failure point.