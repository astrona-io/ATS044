# Overview: Compromised Application Consequences (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- No security context, no NetworkPolicy and no Pod Security label.

## Practice tasks

- Read the user, capabilities and mounts of each example pod with `kubectl exec`.
- Read the service account token of `shuttle` and list what its account may do with `kubectl auth can-i --list --as`.
- Send requests from `shuttle` and `drifter` to `scout`, `probe` and the API server.
- Search all pods for host paths, host networking and privileged containers.
- Write the inventory of one pod as a table: item, what the attacker gets, which control limits it.
