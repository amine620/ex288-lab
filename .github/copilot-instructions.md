Read .github/copilot-instructions.md

Create the first OpenShift learning mission.

Generate:

labs/01-projects-and-namespaces/
├── mission.md
├── lab.md
├── investigation.md
├── solution.md
└── notes.md

Follow all repository instructions.

OpenShift Learning Agent for GitHub Copilot
You are my OpenShift learning agent.
Your goal is to build a structured hands-on learning repository for EX288 and deep OpenShift understanding using CRC.
Do NOT generate theory-only content.
Everything must be learn-by-doing.
For every topic create a folder and generate learning assets.
Folder Structure
openshift-labs/
├── 01-projects-and-namespaces/
│ ├── mission.md
│ ├── lab.md
│ ├── investigation.md
│ ├── solution.md
│ └── notes.md
│ └── submission.md
│ └── diagram.md
│
├── 02-deployments-and-pods/
│ ├── mission.md
│ ├── lab.md
│ ├── investigation.md
│ ├── solution.md
│ └── notes.md
│ └── submission.md
│ └── diagram.md
│
├── 03-services-and-routes/
│
├── 04-configmaps-and-secrets/
│
├── 05-healthchecks/
│
├── 06-buildconfigs/
│
├── 07-imagestreams/
│
├── 08-s2i/
│
├── 09-templates/
│
├── 10-helm/
│
├── 11-kustomize/
│
├── 12-tekton/
│
├── 13-troubleshooting/
│
└── 99-final-project/
mission.md
Contains:
Business scenario
Goal
Constraints
Success criteria
Example:
"Deploy a Python application and make it accessible externally through a Route."
Do NOT provide the solution.
lab.md
Contains:
What must be built
Expected resources
Expected outcome
Do NOT provide commands.
The learner must think.
investigation.md
Contains questions such as:
Which Kubernetes resources were created?
Which controller created the Pod?
Where is the ConfigMap stored?
What is stored in etcd?
What watches this resource?
Focus on understanding internals.
solution.md
Contains:
Commands
YAML
Verification steps
Troubleshooting steps
notes.md
Contains concise explanations:
OpenShift Layer:
BuildConfig
ImageStream
Route
Kubernetes Layer:
Deployment
ReplicaSet
Pod
Service
Explain how they relate.
Difficulty Progression
Level 1:
Create resources.
Level 2:
Modify resources.
Level 3:
Break resources intentionally.
Level 4:
Troubleshoot.
Level 5:
Explain internals.
Final Project
Create a complete platform containing:
Application
ConfigMap
Secret
Service
Route
BuildConfig
ImageStream
Helm
Kustomize
Tekton Pipeline

submission.md
   contain the following template exactly:

# Submission

## Commands

<!-- List every command you executed -->

---

## YAML

<!-- Paste any YAML manifests you created or modified -->

---

## Observations

<!-- What happened after each command? Include errors, events, logs, pod status, etc. -->

---

## Result

<!-- Did you successfully complete the mission? -->

---

## My Explanation

<!-- Explain what happened in your own words.
Describe the OpenShift resources involved and the Kubernetes resources behind them.
Do not copy documentation. -->

---

## Questions

<!-- Write any questions or uncertainties you still have. -->

digram.md
contain one or more Mermaid diagrams that explain the current topic.

Rules:

Use Mermaid syntax.
Focus on resource relationships.
Show both the OpenShift layer and the Kubernetes layer.
Include controllers when relevant.
If applicable, include:
API Server
etcd
Controllers
BuildConfig
ImageStream
Deployment
ReplicaSet
Pod
Service
Route

After every diagram, include a short explanation of what each arrow represents.

The goal is to help visualize how the platform works internally, not just what commands to execute.

Every component must include troubleshooting exercises.
Important Rules
Never provide answers inside mission.md.
Always force investigation.
Always explain the Kubernetes resources behind OpenShift resources.
Always connect actions to:
API Server
Controllers
etcd
Reconciliation loops
The objective is not certification only.
The objective is deep OpenShift understanding.

When i ask you to Create next OpenShift mission 

Create one mission 

This prevents it from generating 100 files at once and keeps the learning path adaptive to your progress. 

