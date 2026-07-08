# Mission 01: Projects and Namespaces

## Business Scenario

Your platform team is preparing a shared CRC OpenShift cluster for two internal application squads. Both squads need isolated workspaces so they can deploy and test safely without impacting each other.

## Goal

Design and create namespace boundaries using OpenShift Projects, then prove that workload and configuration isolation works as expected.

## Constraints

- Use CRC (single-node OpenShift) and keep resource usage small.
- Use only namespaced resources for this mission.
- Do not rely on cluster-wide changes except creating projects.
- Keep all examples reproducible from a clean CRC startup.

## Success Criteria

- Two projects exist for separate environments.
- Each project has its own labels and metadata that reflect ownership.
- A simple workload runs in each project.
- A troubleshooting case is created and resolved.
- You can explain what happened inside API Server, controllers, etcd, and reconciliation loops.

## Difficulty Progression

1. Level 1 - Create: Create two OpenShift Projects and verify corresponding Kubernetes Namespaces.
2. Level 2 - Modify: Add and update labels/annotations to represent team and environment ownership.
3. Level 3 - Break: Intentionally deploy one workload to the wrong project.
4. Level 4 - Troubleshoot: Detect namespace mismatch and move the workload to the correct project.
5. Level 5 - Explain Internals: Describe which control-plane components stored and reacted to each change.

## Deliverable

By the end, you should have isolated project workspaces ready for future missions (Deployments, Services, Routes, ConfigMaps, and Secrets).
