# Question

Solve this question on: `terminal`

In `starfleet`, the service account `shuttle` is bound by the RoleBinding `shuttle-reader` to a Role that lets it read, list and watch every ConfigMap and every Secret in the namespace. The `shuttle` workload only reads one ConfigMap, `shuttle-settings`.

1. Change the access so `shuttle` can only `get` the ConfigMap `shuttle-settings` in `starfleet`.
2. `shuttle` must not read the ConfigMap `other-settings`, list ConfigMaps, or read or list Secrets in any way.
3. Keep the service account `shuttle`, a RoleBinding that names it, and the running Deployment.

`kubectl` already points at the cluster as the cluster administrator. Test any identity with `--as`.
