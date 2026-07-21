# Solution 17: Resource Requests and Limits

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-resource-controls
oc project team-resource-controls
```

## 2) Create Baseline Deployment with Requests and Limits

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-demo
  namespace: team-resource-controls
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resource-demo
  template:
    metadata:
      labels:
        app: resource-demo
    spec:
      containers:
      - name: app
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              dd if=/dev/zero of=/tmp/blob bs=1M count=20 oflag=append conv=notrunc >/dev/null 2>&1
              sleep 10
            done
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 300m
            memory: 256Mi
```

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-demo
  namespace: team-resource-controls
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resource-demo
  template:
    metadata:
      labels:
        app: resource-demo
    spec:
      containers:
      - name: app
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              dd if=/dev/zero of=/tmp/blob bs=1M count=20 oflag=append conv=notrunc >/dev/null 2>&1
              sleep 10
            done
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 300m
            memory: 256Mi
EOF

oc rollout status deployment/resource-demo
oc get pod -l app=resource-demo
```

## 3) Baseline Validation

```bash
oc describe pod $(oc get pod -l app=resource-demo -o jsonpath='{.items[0].metadata.name}')
oc top pod -l app=resource-demo || true
```

## 4) Break Scenario A: Force OOMKilled

Set memory limit lower than workload behavior:

```bash
oc patch deployment resource-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "resources": {
              "requests": {"cpu": "100m", "memory": "64Mi"},
              "limits":   {"cpu": "300m", "memory": "64Mi"}
            }
          }
        ]
      }
    }
  }
}'

oc rollout status deployment/resource-demo --timeout=120s || true
oc get pods -l app=resource-demo
oc describe pod $(oc get pod -l app=resource-demo -o jsonpath='{.items[0].metadata.name}')
oc get events --sort-by='.lastTimestamp' | tail -n 30
```

Expected:
- Container restarts increase.
- Last state reason shows OOMKilled.

## 5) Fix Scenario A

```bash
oc patch deployment resource-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "resources": {
              "requests": {"cpu": "150m", "memory": "192Mi"},
              "limits":   {"cpu": "500m", "memory": "512Mi"}
            }
          }
        ]
      }
    }
  }
}'

oc rollout status deployment/resource-demo
```

## 6) Break Scenario B: Unschedulable Request

Set an unrealistic request for CRC:

```bash
oc patch deployment resource-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "resources": {
              "requests": {"cpu": "8", "memory": "8Gi"},
              "limits":   {"cpu": "8", "memory": "8Gi"}
            }
          }
        ]
      }
    }
  }
}'

oc rollout status deployment/resource-demo --timeout=90s || true
oc get pods -l app=resource-demo
oc describe pod $(oc get pod -l app=resource-demo -o jsonpath='{.items[0].metadata.name}')
oc get events --sort-by='.lastTimestamp' | tail -n 30
```

Expected:
- Pod remains Pending.
- Scheduler events show insufficient cpu or memory.

## 7) Fix Scenario B

```bash
oc patch deployment resource-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "resources": {
              "requests": {"cpu": "200m", "memory": "256Mi"},
              "limits":   {"cpu": "700m", "memory": "768Mi"}
            }
          }
        ]
      }
    }
  }
}'

oc rollout status deployment/resource-demo
oc get pods -l app=resource-demo -o wide
```

## 8) Break Scenario C: Aggressive CPU Limit (Throttling Signal)

```bash
oc patch deployment resource-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "resources": {
              "requests": {"cpu": "100m", "memory": "256Mi"},
              "limits":   {"cpu": "100m", "memory": "768Mi"}
            }
          }
        ]
      }
    }
  }
}'

oc rollout status deployment/resource-demo
oc top pod -l app=resource-demo || true
```

Observe:
- Throughput and responsiveness degrade under load.
- CPU usage plateaus near limit when workload spikes.

## 9) Final Stable Tuning

```bash
oc patch deployment resource-demo --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "app",
            "resources": {
              "requests": {"cpu": "200m", "memory": "256Mi"},
              "limits":   {"cpu": "1", "memory": "768Mi"}
            }
          }
        ]
      }
    }
  }
}'

oc rollout status deployment/resource-demo
oc get deployment,pod -l app=resource-demo
oc describe deployment resource-demo
```

## 10) Verification and Troubleshooting Commands

```bash
oc get events --sort-by='.lastTimestamp' | tail -n 40
oc describe pod $(oc get pod -l app=resource-demo -o jsonpath='{.items[0].metadata.name}')
oc top pod -l app=resource-demo || true
oc get pod -l app=resource-demo -o jsonpath='{.items[0].status.containerStatuses[0].lastState}'
```

## 11) Internal Explanation Checklist

Include these points in your own explanation:
- API Server stores Deployment template and resource values in etcd.
- Deployment controller creates new ReplicaSet on template change.
- ReplicaSet controller creates Pods to match desired replicas.
- Scheduler uses requests against node allocatable capacity for placement.
- Kubelet and Linux cgroups enforce limits at runtime.
- OOMKilled and throttling symptoms appear via container status and events.
- Reconciliation loops keep replacing failed pods until desired state is satisfied.