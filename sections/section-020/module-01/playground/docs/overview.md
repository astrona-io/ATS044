# Overview: Persistence Through Cluster Objects (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- Extra objects in `starfleet` that you search for: a CronJob, a DaemonSet and a ClusterRoleBinding to `cluster-admin`.

## Practice tasks

- List every controller that starts pods, sorted by creation time, and decide which ones the example application needs.
- Delete a pod of `probe` and watch the ReplicaSet create a new one. Then delete the Deployment's owner and watch what happens.
- Read the CronJob in full. Which service account does it use and what can that account do?
- List all ClusterRoleBindings to `cluster-admin` and name the ones that belong to the platform.
- Save one object to a file as evidence before you delete it.
