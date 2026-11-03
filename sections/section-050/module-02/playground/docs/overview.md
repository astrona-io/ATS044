# Overview: Restricting Network Paths With NetworkPolicy (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A `kind` cluster running Kubernetes 1.35 with one control plane node, one worker and the Calico network plugin, which enforces NetworkPolicy.
- The Starfleet workloads with no policy.

## Practice tasks

- Send requests from `shuttle` and `drifter` to `scout` and `probe` before any policy.
- Apply a default deny in `starfleet` and repeat the requests.
- Allow `shuttle` to reach `scout` on port 9898 and test all three paths.
- Allow the whole `outpost` namespace to reach `probe`.
- Add an egress policy to `shuttle` and fix the name lookups with a DNS rule.
