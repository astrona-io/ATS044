---
draft: true
exam_objectives:
  - Kubernetes Trust Boundaries and Data Flow
---
# Trust Boundaries And Security Data Flow

A Kubernetes threat model starts with a list of what the cluster must protect, who can act on it and where those actors can reach it. Without that list, controls are chosen by habit and gaps stay hidden. This module teaches you to build the list from a real cluster and to check each entry with commands.

You work with the `starfleet` namespace of the playground. You read which components hold which authority, which credentials each workload carries, and which interfaces an attacker could touch first.

## Learning Goals

- Identify assets, actors and entry points in a Kubernetes design.
- Trace a request across network, identity and execution boundaries.
- Distinguish trusted control components from untrusted workload inputs.
- Relate each boundary to preventive and detective controls.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments, Services and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with these example workloads. A service account is the identity a pod uses when it calls the Kubernetes API.

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application, each on a service account of the same name |
| `outpost` | `drifter` | A client that belongs to another team |

You run every command as the cluster administrator. Check other identities with `--as`.

## Reading Order

The first part defines assets, actors, entry points and trust boundaries, and ends with a hands-on inventory. The second part follows the credentials that every workload carries and shows how to remove the ones a workload does not use. A short graded task follows the second part.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
