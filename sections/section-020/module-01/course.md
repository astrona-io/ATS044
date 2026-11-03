---
draft: true
exam_objectives:
  - Persistence
---
# Persistence After Workload Compromise

Persistence means an attacker keeps access or keeps running code after the first foothold is removed. In Kubernetes the strongest forms are not in the container at all. They are objects in the API that start new containers, or credentials that stay valid. This module shows how to find those objects and remove them.

## Learning Goals

- Distinguish attacker persistence from ordinary application storage persistence.
- Identify durable configuration, identity and data changes that survive Pod deletion.
- Relate reconciliation to trusted and compromised desired state.
- Describe recovery that restores inputs and revokes authority.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`.

## Reading Order

The first part explains what survives a container replacement and ends with a short inventory of the controllers in the playground. The second part searches a cluster for objects that do not belong, in the order that finds them fastest, and removes them. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
