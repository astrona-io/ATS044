---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Privilege Escalation And Indirect Authority

Privilege escalation means gaining authority beyond the intended starting level. A permission that looks narrow can reach much more through role changes, impersonation or the creation of pods. This module measures the real authority behind a grant and finds the routes that lead to broader access.

## Learning Goals

- Distinguish a direct grant from a route to broader authority.
- Find the verbs that change who holds authority: create on roles and bindings, bind, escalate and impersonate.
- Explain how the creation of a pod can reach host and identity resources.
- Review effective permission with the API server instead of reading role names.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The service account of `shuttle` has a Role named `release-manager` in `starfleet` that is meant to let it update Deployments.

## Reading Order

The first part measures what the `release-manager` Role really allows. The second part follows the creation of workloads to host and identity resources. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
