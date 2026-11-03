# Question

Solve this question on: `terminal`

The service account `shuttle` in `starfleet` runs a release job. Its task is to set a new image on Deployments. The Role `release-manager` grants more than that.

1. Read the Role and write down which rights are not needed for the task.
2. Change the Role so that `shuttle` may only `get`, `list` and `patch` Deployments.
3. `shuttle` must not be able to create roles or role bindings or to run commands in pods. Do not delete the binding or any workload.

`kubectl` already points at the cluster as the cluster administrator.
