# Mission 05: Security Context Constraints (SCC)

## Business Scenario

A legacy internal web container must run with a fixed root user for compatibility, while your platform baseline enforces restricted security defaults. Your team must deploy safely on CRC without weakening cluster-wide security.

## Goal

Deploy an application that initially fails SCC admission, diagnose the exact SCC-related failure, then fix it with the minimum-privilege approach using dedicated ServiceAccounts and targeted SCC binding.

## Constraints

- CRC compatible only.
- Use a dedicated mission project.
- Do not change cluster-wide defaults for all workloads.
- Scope elevated SCC access only to the workload that needs it.
- Keep a clear audit trail of what changed and why.

## Success Criteria

- Workload fails first because of SCC constraints.
- Failure is diagnosed using events and object descriptions.
- Workload succeeds after controlled SCC assignment to a dedicated ServiceAccount.
- You can explain how SCC admission connects to API Server, etcd, and reconciliation loops.
- You can identify the Kubernetes objects still involved behind OpenShift SCC.

## Difficulty Progression

1. Level 1 - Create: Create project, ServiceAccount, and baseline Deployment.
2. Level 2 - Modify: Apply pod-level securityContext that conflicts with restricted SCC.
3. Level 3 - Break: Trigger admission denial and pending/uncreated pod behavior.
4. Level 4 - Troubleshoot: Inspect events, SCC resolution, and ServiceAccount bindings.
5. Level 5 - Explain Internals: Explain SCC admission path and downstream controller behavior.

## Deliverable

A complete `05-security-context-constraints` mission with one intentional SCC denial, one least-privilege fix, verification evidence, and internals-focused explanations.
