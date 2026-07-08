# Mission 09: Build Triggers and Build Hooks

## Business Scenario

Your team uses Git-based workflows on CRC. When developers push code to a Git repository, you want builds to start automatically without running `oc start-build` manually. Additionally, you need build hooks to run custom logic before and after the build completes—for example, running tests after building the image or notifying external systems.

Your mission: Configure a BuildConfig with Git triggers that automatically start builds on push, add pre-build and post-build hooks to run custom scripts, intentionally trigger builds via Git webhooks, and explain how the webhook controller and build hooks interact within OpenShift's reconciliation model.

## Goal

Understand build automation via triggers and custom hooks, configure Git webhooks in BuildConfig, implement pre/post-build hook scripts, trigger and verify automatic builds, diagnose trigger failures, and explain how OpenShift controllers watch Git events and reconcile build state.

## Constraints

- Use CRC-compatible setup without external Git hosting (simulate Git updates).
- Work in a dedicated mission project.
- Use BuildConfig with Git source strategy (S2I or Docker).
- Configure ConfigChange and ImageChange triggers.
- Implement pre-build and post-build hooks with real commands.
- Do NOT rely on external GitHub/GitLab; simulate Git push events.
- Keep all steps reproducible from a clean CRC start.

## Success Criteria

- A BuildConfig is configured with Git source and automatic triggers.
- ConfigChange trigger automatically starts new builds when BuildConfig changes.
- ImageChange trigger automatically starts builds when base image updates.
- Pre-build hooks execute custom logic before Docker/S2I build.
- Post-build hooks execute custom logic after image push completes.
- Builds are triggered manually via webhook (simulated).
- Build logs show hook execution and any hook failures.
- You can explain the difference between trigger types and when each fires.
- You can describe how the trigger controller and build pod execute hooks.

## Difficulty Progression

1. Level 1 - Create: Create BuildConfig with Git source and basic ConfigChange trigger.
2. Level 2 - Modify: Add ImageChange trigger and pre/post-build hooks.
3. Level 3 - Break: Trigger build failures in hooks (script errors, timeouts).
4. Level 4 - Troubleshoot: Diagnose hook failures using logs and events.
5. Level 5 - Explain Internals: Describe trigger evaluation, hook execution, and reconciliation.

## Deliverable

A complete `09-build-triggers-hooks` lab workspace with working Git-triggered builds, functional pre/post-build hooks, intentional failure scenarios, and internals-focused explanations.
