# Mission 10: Build Troubleshooting

## Business Scenario

Your team has deployed multiple BuildConfigs on CRC to automate application building. However, builds are failing silently—some complete successfully but push to the wrong registry, others fail during S2I assembly, and some never start due to missing credentials or Git authentication issues.

Your mission: Diagnose build failures by accessing build pod logs, interpreting error messages, troubleshooting S2I assemble script failures, resolving registry authentication errors, fixing Git clone failures, and explaining how the Build Pod executes and logs are structured in OpenShift.

## Goal

Master build failure diagnosis using logs, events, and introspection; understand common failure modes (missing credentials, Git auth, assemble script errors); learn to access build pod logs before they're garbage-collected; correlate build failures to resource quotas, image availability, and controller state; explain how the Build Pod reconciliation loop reports errors to the API Server.

## Constraints

- Work on CRC with limited resources (prevent OOMKilled scenarios).
- Intentionally break builds to reproduce failure modes.
- Do not fix failures until you've diagnosed them with logs.
- Access build logs via `oc logs` and `oc describe`, not console UI.
- Use realistic Git repository or local Git simulation.
- Verify fixes by triggering new builds and confirming success.

## Success Criteria

- You can access build pod logs before pod cleanup.
- You can diagnose S2I assemble script failures from log output.
- You can identify and resolve registry push authentication failures.
- You can troubleshoot Git clone failures (bad URI, missing SSH key).
- You can interpret build events and correlate them to controller actions.
- You understand why builds fail and how etcd tracks failure state.
- You can explain the Build Pod's relationship to BuildConfig and Build objects.

## Difficulty Progression

1. Level 1 - Observe: Run a build that succeeds and examine logs.
2. Level 2 - Diagnose: Run a build that fails and read error messages.
3. Level 3 - Break: Intentionally break a build in multiple ways.
4. Level 4 - Fix: Resolve failures by correcting BuildConfig or environment.
5. Level 5 - Explain Internals: Describe build pod lifecycle, log storage, failure propagation, and reconciliation.

## Deliverable

A complete `10-build-troubleshooting` lab workspace with working and failing builds, diagnostic steps for each failure mode, logs archived for reference, and internals-focused explanations of build failure handling.
