# Question

Solve this question on: `terminal`

A review found objects in `starfleet` that the deployment pipeline did not create. Remove them. Do not touch the four example Deployments (`scout`, `probe`, `shuttle` in `starfleet` and `drifter` in `outpost`).

1. A CronJob starts a Job every minute. Remove it, so no Job or pod from it exists.
2. A DaemonSet runs one pod per node and the application does not use it. Remove it.
3. The service account that the CronJob uses is bound to `cluster-admin`. Remove that grant.

`kubectl` already points at the cluster as the cluster administrator.
