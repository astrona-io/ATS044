# Question

Solve this question on: `terminal`

Two routes to broader authority exist in `starfleet`. Close both and keep the release job working.

1. The Role `release-manager` lets `shuttle` create roles and role bindings and run commands in pods. Reduce it to `get`, `list` and `patch` on Deployments.
2. The namespace accepts privileged pods and host paths. Enforce the Pod Security Admission `baseline` level.
3. A plain pod must still be accepted. Do not delete or scale the workloads.

`kubectl` already points at the cluster as the cluster administrator.
