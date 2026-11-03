---
draft: true
exam_objectives:
  - Denial of Service
---
# Bounding Resource Consumption

A denial of service happens when legitimate users cannot use a service because a shared resource is used up. In a cluster the shared resources are node CPU and memory, pod slots and storage. This module shows how Kubernetes decides who gets those resources and how to cap what one workload or one namespace can take.

## Learning Goals

- Compare requests, limits, quotas and limit ranges and say which boundary each one protects.
- Read the quality of service class of a pod and predict what happens under memory pressure.
- Write a ResourceQuota and a LimitRange for a namespace.
- Explain why a quota cannot create capacity.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. You also need `jq` on your machine for one check.

## Reading Order

The first part explains requests, limits, scheduling and eviction, and reads them from the running pods. The second part caps a whole namespace with a ResourceQuota and gives every container sensible defaults with a LimitRange. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
