# Question

Solve this question on: `terminal`

The pod of the Deployment `drifter` in `outpost` is suspected to be compromised. Stop it from doing harm over the network but keep it running, so its evidence stays.

1. Block all outgoing traffic of the `drifter` pods with a NetworkPolicy in `outpost`.
2. Do not affect the other workloads: `shuttle` must still reach `scout`.
3. Do not delete the pod or the Deployment.

The cluster runs a network plugin that enforces NetworkPolicy. `kubectl` already points at the cluster as the cluster administrator.
