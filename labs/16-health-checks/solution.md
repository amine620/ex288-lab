# Solution 16: Health Checks and Probe Strategy

## 1) Project Setup (CRC Compatible)

```bash
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc new-project team-health-checks
oc project team-health-checks
```

## 2) Deploy Probe-Aware App

```bash
oc apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-demo
  namespace: team-health-checks
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe-demo
  template:
    metadata:
      labels:
        app: probe-demo
    spec:
      containers:
      - name: app
        image: registry.access.redhat.com/ubi9/python-311:latest
        command: ["/bin/bash", "-c"]
        args:
          - |
            cat > /tmp/app.py <<'PY'
            from http.server import BaseHTTPRequestHandler, HTTPServer
            import time
            start = time.time()
            class H(BaseHTTPRequestHandler):
                def do_GET(self):
                    uptime = time.time() - start
                    if self.path == '/startup':
                        if uptime > 20:
                            self.send_response(200)
                        else:
                            self.send_response(503)
                    elif self.path == '/ready':
                        if uptime > 15:
                            self.send_response(200)
                        else:
                            self.send_response(503)
                    elif self.path == '/health':
                        self.send_response(200)
                    else:
                        self.send_response(404)
                    self.end_headers()
                    self.wfile.write(f'uptime={uptime:.1f}'.encode())
            HTTPServer(('0.0.0.0', 8080), H).serve_forever()
            PY
            python /tmp/app.py
        ports:
        - containerPort: 8080
        startupProbe:
          httpGet:
            path: /startup
            port: 8080
          periodSeconds: 3
          failureThreshold: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          periodSeconds: 3
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          periodSeconds: 5
          failureThreshold: 3
EOF

oc rollout status deployment/probe-demo
```

## 3) Create Service and Validate Endpoints

```bash
oc expose deployment probe-demo --port=8080 --name=probe-demo
oc get svc probe-demo
oc get endpoints probe-demo
oc get pod -l app=probe-demo -w
```

## 4) Baseline Verification

```bash
POD=$(oc get pod -l app=probe-demo -o jsonpath='{.items[0].metadata.name}')
oc describe pod "$POD" | sed -n '/Readiness/,/Events/p'
oc exec "$POD" -- curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/startup
oc exec "$POD" -- curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/ready
oc exec "$POD" -- curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/health
```

## 5) Break Scenario A: Wrong Readiness Path

```bash
oc patch deployment probe-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'

oc rollout status deployment/probe-demo --timeout=90s || true
POD=$(oc get pod -l app=probe-demo -o jsonpath='{.items[0].metadata.name}')
oc get pod "$POD"
oc describe pod "$POD" | tail -n 30
oc get endpoints probe-demo
```

Expected:
- Pod is Running but not Ready.
- Service endpoints are empty or missing this pod.

## 6) Fix Scenario A

```bash
oc patch deployment probe-demo --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ready"}]'
oc rollout status deployment/probe-demo
oc get endpoints probe-demo
```

## 7) Break Scenario B: Aggressive Liveness

```bash
oc patch deployment probe-demo --type='json' \
  -p='[
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/periodSeconds","value":2},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/failureThreshold","value":1},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/wrong-health"}
  ]'

oc rollout status deployment/probe-demo --timeout=90s || true
oc get pods -l app=probe-demo -w
POD=$(oc get pod -l app=probe-demo -o jsonpath='{.items[0].metadata.name}')
oc describe pod "$POD" | tail -n 40
```

Expected:
- Restarts increase.
- Events show liveness failures and container restarts.

## 8) Fix Scenario B

```bash
oc patch deployment probe-demo --type='json' \
  -p='[
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/health"},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/periodSeconds","value":5},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/failureThreshold","value":3}
  ]'
oc rollout status deployment/probe-demo
```

## 9) Break Scenario C: Remove Startup Probe for Slow Start

```bash
oc patch deployment probe-demo --type='json' \
  -p='[{"op":"remove","path":"/spec/template/spec/containers/0/startupProbe"}]'

oc patch deployment probe-demo --type='json' \
  -p='[
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/ready"},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/periodSeconds","value":3},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/failureThreshold","value":1}
  ]'

oc rollout status deployment/probe-demo --timeout=90s || true
oc get events --sort-by='.lastTimestamp' | tail -n 25
```

Expected:
- Liveness can fail during startup window.
- Pod restarts before app fully initializes.

## 10) Fix Scenario C (Reintroduce Startup Probe)

```bash
oc patch deployment probe-demo --type='json' \
  -p='[
    {"op":"add","path":"/spec/template/spec/containers/0/startupProbe","value":{"httpGet":{"path":"/startup","port":8080},"periodSeconds":3,"failureThreshold":10}},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/health"},
    {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/failureThreshold","value":3}
  ]'

oc rollout status deployment/probe-demo
```

## 11) Verification Commands

```bash
oc get deployment,replicaset,pod,svc,endpoints
oc describe deployment probe-demo
oc describe pod $(oc get pod -l app=probe-demo -o jsonpath='{.items[0].metadata.name}')
oc get events --sort-by='.lastTimestamp' | tail -n 40
```

## 12) Troubleshooting Quick Reference

- Readiness problems:
  - `oc describe pod <pod>`
  - `oc get endpoints <service>`
  - verify readiness path and app response code
- Liveness restart loops:
  - `oc get pod <pod> -o wide`
  - `oc describe pod <pod>`
  - inspect restart count and probe failures
- Startup instability:
  - ensure `startupProbe` covers worst-case boot time
  - keep liveness strictness after startup succeeds

## 13) Internal Explanation Checklist

When writing your explanation, include:
- API Server stores probe specs in etcd.
- Deployment controller and ReplicaSet controller reconcile pods after spec changes.
- Kubelet executes probe loops and reports condition updates.
- Endpoints/EndpointSlice updates depend on pod readiness.
- Reconciliation loops converge to stable traffic and health behavior.