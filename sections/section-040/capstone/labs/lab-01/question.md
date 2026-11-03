# Question

Solve this question on: `terminal`

Two workloads need action.

1. `shuttle` in `starfleet` will process input from an untrusted source. Harden its container: a non-root numeric user (use `10001`), no privilege escalation, all capabilities dropped and a read-only root file system. It must keep running.
2. `drifter` in `outpost` is suspected to be compromised. Block all its outgoing traffic with a NetworkPolicy and keep the pod running.
3. After both changes, `shuttle` must still reach `scout`.

The cluster enforces NetworkPolicy. `kubectl` already points at the cluster as the cluster administrator.
