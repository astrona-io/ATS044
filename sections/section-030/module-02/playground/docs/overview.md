# Overview: API Protection And Availability (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- The service account `batch-importer` in `starfleet`, with no permissions.

## Practice tasks

- List the built-in flow schemas and levels and sort them by matching precedence.
- Create a priority level and a flow schema for `batch-importer` and send requests with `--as`.
- Read the APF metrics and find the counters of your flow schema.
- Scale `probe` to two replicas, add a PodDisruptionBudget and read its allowed disruptions.
- Scale `probe` back to one replica and read the allowed disruptions again.
