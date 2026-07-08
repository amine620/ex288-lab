# Notes 09: Build Triggers and Hooks

## Mission Focus

### Build Triggers (OpenShift)

Automatic build initiation in response to changes:

- **ConfigChange**: Fires when BuildConfig itself is modified.
- **ImageChange**: Fires when source ImageStream tag is updated.
- **GitHub/GitLab**: Webhook-based triggers on Git push events.

### Build Hooks (OpenShift)

Custom scripts executed at specific points during build:

- **Pre-build**: Runs before source strategy (S2I) or Docker build step. Failure aborts build.
- **Post-build**: Runs after image is successfully pushed to registry. Failure does not prevent push.

## OpenShift Layer

### BuildConfig

- Declarative build definition with source, strategy, output, and triggers.
- Changes to BuildConfig trigger ConfigChange trigger.

### Build Controller

- Watches for trigger conditions and creates new Build objects.
- Reconciliation: trigger condition met → Build created → build pod scheduled.

### ImageStream

- Image reference used by ImageChange trigger.
- Updates to tags trigger builds in dependent BuildConfigs.

## Kubernetes Layer

### Build Pod

- Executes build strategy (S2I or Docker).
- Executes pre-build and post-build hooks.
- Runs as `builder` ServiceAccount with registry push credentials.

### Events

- Record trigger evaluations, build creations, and hook execution.
- Visible via `oc get events`.

## Trigger Workflow

1. **Trigger Condition**: ConfigChange, ImageChange, or webhook event detected.
2. **Build Controller** observes condition via API Server watch.
3. **Build Object** created in etcd with new build run.
4. **Build Pod** scheduled and executed.
5. **Pre-build Hook** executes (if defined).
6. **Build Strategy** (S2I or Docker) executes.
7. **Image Push** to registry.
8. **Post-build Hook** executes (if defined).
9. **ImageStream** updated with new image digest.

## Hook Execution Semantics

- **Pre-build hook failure** (exit code != 0): Build is aborted, post-build hook does not run.
- **Post-build hook failure** (exit code != 0): Build is marked succeeded, but hook failure is logged.

## Relationship Summary

- BuildConfig → Build Controller watches for triggers.
- Trigger fires → Build object created.
- Build object → Build pod scheduled and executed.
- Build pod executes hooks and build strategy.
- Image push → ImageStream updated.
- ImageStream change → ImageChange trigger fires in dependent BuildConfigs.
- All state persisted in etcd, all events tracked via API Server.
