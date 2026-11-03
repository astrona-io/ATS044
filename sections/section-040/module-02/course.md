---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Containing And Recovering A Compromised Workload

After a compromise, the goal is to reduce what the process can do, stop it from reaching other systems, keep evidence and return to a trusted state. This module shows the container settings that reduce the damage and the steps of isolation and recovery.

## Learning Goals

- Set a securityContext that removes common attacker options.
- Describe what Pod Security Admission enforces.
- Isolate a pod with a NetworkPolicy while keeping its evidence.
- Verify that a replacement pod runs a trusted artifact.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The isolation steps use NetworkPolicy, so the playground runs the Calico network plugin.

## Reading Order

The first part sets the container settings that limit a compromised process. The second part isolates a workload, collects evidence and checks that the replacement is trusted. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
