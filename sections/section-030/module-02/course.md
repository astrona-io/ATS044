---
draft: true
exam_objectives:
  - Denial of Service
---
# Protecting The API Server And Applications

The API server is shared by every controller and every user, and an application needs capacity to survive a loss. This module shows how API Priority and Fairness protects the API, where small requests turn into large amounts of work, and how a PodDisruptionBudget and spare capacity keep an application running.

## Learning Goals

- Describe how a FlowSchema and a PriorityLevelConfiguration classify and queue requests.
- Write a rule that limits one service account.
- List the places where one request multiplies into many.
- Write a PodDisruptionBudget and explain what it does and does not protect.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`.

## Reading Order

The first part covers API Priority and Fairness with a rule for a noisy service account. The second part covers amplification, the caps that limit it, PodDisruptionBudgets and recovery capacity. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
