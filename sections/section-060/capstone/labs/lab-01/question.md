# Question

Solve this question on: `terminal`

Two paths expose the database password in `report-db` in `starfleet`. Close both and keep the workloads running.

1. The service account `shuttle` can read every Secret in the namespace through the Role `shuttle-secrets`. It must only `get` the Secret `shuttle-token`.
2. The Deployment `probe` receives the password through the environment variable `DB_PASSWORD`. Mount the Secret `report-db` as a read-only volume at `/etc/report-db` and remove the variable.
3. Do not delete the Secrets, the Role or any workload.

`kubectl` already points at the cluster as the cluster administrator.
