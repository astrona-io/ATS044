---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Compromised Application Consequences

When an attacker runs code inside a container, the code gets the identity, files, credentials and network paths of that container. This module shows how to list exactly what a compromised process can reach, so you can separate the effects of an application compromise from a container escape.

## Learning Goals

- Distinguish application compromise from container escape.
- Read the user, capabilities, mounts and credentials of a running container.
- Test which services a pod can reach on the network.
- Explain which effects a compromise has without any escape.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. You use `kubectl exec` to run commands inside the example pods. In a real incident the attacker does the same from inside the process.

## Reading Order

The first part explains the boundaries around a container and reads the process identity and file system from inside the pod. The second part builds an inventory of the credentials and network paths that the process can use.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
