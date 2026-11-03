---
draft: true
exam_objectives:
  - Persistence
---
# Persistence Through Credentials And Nodes

Some persistence needs no new workload. A credential that never expires, or a pod that writes to the host, keeps working after every pod and controller has been cleaned. This module shows these two routes and how to close them: replace long-lived tokens with short-lived ones and stop pods from mounting the node's files.

## Learning Goals

- Explain why a long-lived service account token Secret persists after a pod is deleted.
- Create and inspect a short-lived token with an expiry.
- Find pods that mount host paths and explain what they can change on the node.
- Apply the baseline Pod Security level to stop host path mounts.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. You also need `jq` on your machine for one search.

## Reading Order

The first part follows credentials: how a token is issued, why some never expire, and how to find and remove them. The second part follows the node: what a host path mount lets a pod change, how admission blocks it and what recovery looks like when a node was touched. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
