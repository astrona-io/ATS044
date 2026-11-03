# Question

Solve this question on: `terminal`

The service account `shuttle` in `starfleet` can read every Secret in the namespace, including the database password in `report-db`. It needs to read only the Secret `shuttle-token`.

1. Find the Role that grants the access and the binding that connects it to `shuttle`.
2. Change the Role `shuttle-secrets` so that `shuttle` may only `get` the Secret `shuttle-token`.
3. `shuttle` must not be able to list Secrets or read `report-db`. Do not delete the Role binding or any workload.

`kubectl` already points at the cluster as the cluster administrator.
