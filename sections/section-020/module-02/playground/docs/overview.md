# Overview: Persistence Through Credentials And Nodes (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- In `starfleet`: the service account `ci-runner`, its legacy token Secret `ci-runner-token` and the Deployment `node-agent`, which mounts `/etc` from the node.

## Practice tasks

- Request a short-lived token for `shuttle` and decode its claims. Compare it with the claims of `ci-runner-token`.
- Search all namespaces for Secrets of type `kubernetes.io/service-account-token`.
- Search all pods for `hostPath` volumes and host namespaces.
- Label `outpost` with the `baseline` level and try to create a pod that mounts a host path there.
- Run the label command with `--dry-run=server` on `starfleet` and read the warning about `node-agent`.
