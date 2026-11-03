---
draft: true
exam_objectives:
  - Kubernetes Trust Boundaries and Data Flow
---
# Trust Boundaries And Request Data Flow

Data in a cluster moves along a few fixed paths: from a client to the API server, from the API server to etcd and the nodes, and from pod to pod through Services. Each path crosses a boundary where the cluster either checks something or checks nothing. This module shows which checks exist on each path and how to see them.

You send real requests to the API server and between pods in the playground, and you read what each layer answers.

## Learning Goals

- Describe the order of authentication, authorization and admission for an API request.
- Tell apart a request rejected for identity from one rejected for permission.
- Show that pod-to-pod traffic has no identity check unless a control adds one.
- Restrict a workload to the one object it reads.

## Before You Start

You need `kubectl` basics and the idea of a service account. The playground is a kind cluster running Kubernetes 1.35. It holds the `scout`, `probe` and `shuttle` workloads in `starfleet`, the `drifter` workload in `outpost`, and a service account for each. You run commands as the cluster administrator and test other identities with `--as`.

## Reading Order

The first part follows an API request through the API server and tests each decision. The second part follows pod-to-pod traffic and shows what the network layer does and does not check. A graded task follows the second part.

Start your playground now:

<!-- astrona:playground -->
