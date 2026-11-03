# Question

Solve this question on: `terminal`

A suspected compromise left four things behind. Remove them and keep the example application running (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in `outpost`).

1. A CronJob in `starfleet` that the pipeline did not create, and the grant that gives its identity full cluster access.
2. A Secret that holds a token for `shuttle` that never expires.
3. A Deployment in `outpost` that mounts a node directory.
4. Make `outpost` enforce the `baseline` Pod Security level, so a pod with a host path cannot start there again.

`kubectl` already points at the cluster as the cluster administrator.
