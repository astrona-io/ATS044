---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Limiting And Recovering From Disclosure

A credential reaches a process by an environment variable or by a file, and each choice exposes it differently. This module compares the two delivery methods, limits who can read a Secret and then rotates a credential so that the old value stops working.

## Learning Goals

- Compare environment variables with mounted files for delivering a Secret.
- Limit a Secret to the one container that needs it.
- Rotate a Secret and explain when a running pod sees the new value.
- Describe what revocation recovers and what it cannot.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The workload `probe` in this playground reads a database password from the Secret `report-db` through an environment variable.

## Reading Order

The first part compares the delivery methods and changes the delivery of the password. The second part rotates the password and follows the new value to the pod. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
