---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Preventing Escalation With Controls

Each escalation route has a control that stops it. This module narrows a Role to the verbs that a job needs, then uses Pod Security Admission to reject dangerous pod declarations, and then protects those controls from change.

## Learning Goals

- Write a Role that grants only the verbs and objects that a task needs.
- Explain the three Pod Security Admission levels and the three modes.
- Enforce a level on a namespace and prove it with accepted and rejected requests.
- Describe who must not be able to change the controls.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The service account of `shuttle` has a Role named `release-manager` in `starfleet` that grants more than a release job needs. The namespace has no Pod Security Admission label.

## Reading Order

The first part narrows the Role and tests the result. The second part enforces a Pod Security Admission level and protects it. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
