---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Network Attackers And Peer Trust

An attacker on the network can try to read traffic, change it, pretend to be a service or reach a service that should be private. This module shows how to check what the network lets a client do, how TLS (Transport Layer Security) proves the identity of a server, how to find the stage where a request fails, and how timeouts and retries change the load on a service.

## Learning Goals

- Explain what TLS verification checks and what fails when a check is missing.
- Find the stage of a request path where a connection fails.
- Read the evidence that a request leaves.
- Describe how retries and timeouts affect an overloaded service.

## Before You Start

You need Kubernetes basics: namespaces, pods, Deployments and `kubectl get`. The playground is a kind cluster running Kubernetes 1.35 with the example workloads `scout`, `probe` and `shuttle` in `starfleet` and `drifter` in `outpost`, each on its own service account. You run every command as the cluster administrator and test other identities with `--as`. The playground starts with a Service called `radar` that is broken on purpose, so there is a real failure to investigate.

## Reading Order

The first part separates encryption, authentication and authorization and checks TLS verification against the API server. The second part walks a request through name resolution, Service, endpoints, port and listener to find a fault. A graded task follows the second part. The third part covers request evidence, timeouts and retries.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
