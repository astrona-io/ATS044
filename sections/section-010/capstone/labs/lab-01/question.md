# Question

Solve this question on: `terminal`

A review of `starfleet` and `outpost` found three authorities that no workload needs. Remove them without deleting any Deployment or service account.

1. The service account `drifter` in `outpost` can read pods and other objects in every namespace. It must have no access to the API beyond what every authenticated identity has.
2. The `shuttle` pods in `starfleet` must not mount a service account token. `shuttle` never calls the API.
3. The service account `probe` in `starfleet` must not be able to `get` or `list` Secrets.

All four Deployments (`scout`, `probe`, `shuttle` and `drifter`) must stay available.

`kubectl` already points at the cluster as the cluster administrator.
