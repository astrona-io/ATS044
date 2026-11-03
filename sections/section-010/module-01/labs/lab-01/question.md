# Question

Solve this question on: `terminal`

The namespaces `starfleet` and `outpost` are running. Security review found that none of the four workloads calls the Kubernetes API, yet every pod mounts a service account token. Remove the token from all of them. Do not delete or recreate the Deployments, and keep every workload running.

1. In `starfleet`, the Deployments `scout`, `probe` and `shuttle` must start pods that mount no service account token.
2. In `outpost`, the Deployment `drifter` must do the same.
3. All four Deployments must finish rolling out with ready pods.

`kubectl` already points at the cluster as the cluster administrator.
