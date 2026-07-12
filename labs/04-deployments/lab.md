# Lab 04: Build Requirements

## What You Must Build

- Create and use mission project:
  - `team-alpha-deploy`
- Create one Deployment with 2 replicas.
- Expose rollout behavior by changing image version.
- Intentionally trigger one failed rollout.
- Recover the application with rollback.

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 1 Deployment
- Multiple ReplicaSets over time (revision history)
- Pods managed by active ReplicaSet
- Events and rollout history proving failure and recovery

## Expected Outcome

- Deployment maintains desired replicas.
- Rolling update creates new ReplicaSet and gradually replaces old Pods.
- Failed rollout is detected and reversed.
- You can explain Deployment-to-ReplicaSet ownership and reconciliation flow.

## Troubleshooting Scenarios To Include

- Scenario A: rollout blocked due to invalid image tag.
- Scenario B: resource appears missing due to wrong active project.
- Scenario C: old ReplicaSet still exists but scaled down; identify active revision.

## Completion Checklist

- Deployment created and verified
- Rolling update completed
- Failed rollout reproduced and diagnosed
- Rollback completed successfully
- Internals explanation documented
