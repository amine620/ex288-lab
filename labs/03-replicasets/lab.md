# Lab 03: Build Requirements

## What You Must Build

- Create and use a mission project:
  - `team-alpha-rs`
- Create one ReplicaSet that targets 2 Pods.
- Apply labels that clearly connect selector and Pod template.
- Scale the ReplicaSet to a higher count, then back down.
- Intentionally break a selector/template alignment scenario and recover.

## Expected Resources

- 1 OpenShift Project and backing Kubernetes Namespace
- 1 ReplicaSet resource
- Multiple Pods managed by that ReplicaSet
- Events and status evidence showing reconciliation and recovery

## Expected Outcome

- Pod replacement happens automatically when a managed Pod is deleted.
- Scaling operations change Pod count to the declared desired state.
- Break/fix cycle demonstrates why selectors and labels are critical.
- You can explain controller behavior and API persistence flow.

## Troubleshooting Scenarios To Include

- Scenario A: Deleting a managed Pod and observing automatic replacement.
- Scenario B: Selector/template label mismatch causing unexpected Pod ownership behavior.
- Scenario C: Wrong project context makes resources appear missing.

## Completion Checklist

- Mission project created and active
- ReplicaSet created and verified
- Scale up/down verified
- One intentional break/fix completed
- Troubleshooting evidence and internals explanation documented
