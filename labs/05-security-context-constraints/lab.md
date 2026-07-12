# Lab 05: Build Requirements

## What You Must Build

- Create and use mission project:
  - `team-alpha-scc`
- Create a dedicated ServiceAccount for the legacy workload.
- Create a Deployment that requests root execution and fails SCC admission under default policy.
- Diagnose why ReplicaSet cannot create Pods.
- Apply a targeted SCC binding to only the dedicated ServiceAccount.
- Re-run and verify workload becomes healthy.

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 1 ServiceAccount (`legacy-sa`)
- 1 Deployment (`legacy-web`)
- 1 ReplicaSet with admission failure evidence before fix
- Pod(s) running only after SCC binding fix
- Role/authorization change proving scoped SCC grant

## Expected Outcome

- Before fix: Deployment exists, ReplicaSet exists, Pod creation denied by SCC admission.
- After fix: Deployment converges to desired replicas and pods are Running.
- You can prove which SCC was selected and why.

## Troubleshooting Scenarios To Include

- Scenario A: Wrong project context causes misleading "not found" or empty results.
- Scenario B: SCC denial with `runAsUser: 0` blocked by restricted SCC.
- Scenario C: SCC granted to wrong ServiceAccount; workload still fails.
- Scenario D: Overly broad grant risk; justify least-privilege correction.

## Completion Checklist

- Mission project created and selected
- Failing SCC scenario reproduced
- Admission/event evidence captured
- Targeted SCC binding applied to correct ServiceAccount
- Workload recovered and verified
- Internals explanation completed
