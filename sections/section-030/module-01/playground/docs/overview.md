# Overview: Resource Consumption Boundaries (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- No ResourceQuota and no LimitRange in any namespace.

## Practice tasks

- Read the requests, limits and QoS class of each example pod and compare the three.
- Add a quota with a `pods` limit of 3 to `outpost` and scale `drifter` to 5. Read the events of the ReplicaSet.
- Add a LimitRange with a default memory limit, create a pod without resources and read what it received.
- Add a `max` memory value that is lower than the request of a pod and read the error message.
- Compare the sum of the requests in the cluster with the allocatable values of the node.
