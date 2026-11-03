---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Restricting Network Paths With NetworkPolicy

By default, every pod in a Kubernetes cluster can send traffic to every other pod. An attacker who controls one pod therefore reaches all of them. A NetworkPolicy changes that default for the pods that it selects. This module explains how a policy selects pods, how a default deny works and how to allow only the traffic that an application needs.

## Learning Goals

- Explain how a NetworkPolicy selects pods and what changes for them.
- Write a default-deny policy and explicit allow rules.
- Allow traffic by pod label and by namespace.
- Prove a policy with allowed and blocked requests.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The playground runs the Calico network plugin, which enforces NetworkPolicy.

## Reading Order

The first part explains the mechanism and builds a default deny. The second part adds allow rules, namespace selectors and DNS, and tests each rule with real requests. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
