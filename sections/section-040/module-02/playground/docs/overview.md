# Overview: Containing A Compromised Workload (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A `kind` cluster running Kubernetes 1.35 with one control plane node, one worker and the Calico network plugin, which enforces NetworkPolicy.
- The Starfleet workloads, unhardened.

## Practice tasks

- Add a security context to `drifter` and prove each field with a command that now fails.
- Label `outpost` with `pod-security.kubernetes.io/warn=restricted` and dry-run a pod.
- Isolate `drifter` with an empty NetworkPolicy and prove it with a request. Check that `shuttle` still works.
- Save the pod specification, log and image digest of `drifter` as evidence.
- Roll the Deployment out again and compare the image digest.
