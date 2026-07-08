# Lab 01: Build Requirements

## What You Must Build

- Create two OpenShift projects:
  - `team-alpha-dev`
  - `team-alpha-test`
- Add ownership metadata:
  - `team=alpha`
  - `env=dev` or `env=test`
- Deploy one minimal pod or deployment in each project.
- Intentionally place one test workload in the wrong project first, then correct it.

## Expected Resources

- 2 OpenShift Projects
- 2 Kubernetes Namespaces (backing the projects)
- 2 workloads (one per project after fix)
- Namespace labels and annotations showing team/environment ownership

## Expected Outcome

- Workloads are isolated per project.
- Resource listings differ by active project context.
- The wrong-namespace deployment issue is identified and fixed.
- You can articulate resource lifecycle from API request to controller reconciliation.

## Troubleshooting Scenarios To Include

- Scenario A: Workload appears missing because you are in the wrong project context.
- Scenario B: Workload name collision happens across namespaces and is resolved by using the correct target namespace.
- Scenario C: Label mismatch causes confusion in filtering and is corrected.

## Completion Checklist

- Project isolation validated
- Context switching validated
- Troubleshooting evidence captured
- Internal behavior explained in investigation answers
