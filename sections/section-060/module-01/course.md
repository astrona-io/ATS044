---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Sensitive Data Access Paths

A Secret is only one place where sensitive data lives. Values also appear in environments, mounted files, logs and backups, and many identities can read them through direct and indirect permissions. This module lists every copy and every reader of a credential and then tests who can read it.

## Learning Goals

- Find sensitive data in live resources, mounted files and retained copies.
- Explain why base64 is encoding and not encryption.
- List the identities that can read a Secret directly.
- Find indirect routes to the same data, such as exec, logs and pod creation.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The playground adds two Secrets, `report-db` and `shuttle-token`, and a Role that lets the service account of `shuttle` read every Secret in `starfleet`.

## Reading Order

The first part decodes a Secret and finds the identities that can read it directly. The second part finds the indirect routes and the retained copies. A graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
