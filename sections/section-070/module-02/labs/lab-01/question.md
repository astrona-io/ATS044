# Question

Solve this question on: `terminal`

The namespace `starfleet` has no admission control for pod content. A privileged pod and a pod with a `hostPath` volume are accepted.

1. Enforce the Pod Security Admission `baseline` level on the namespace `starfleet`.
2. A privileged pod and a pod that mounts a host path must be rejected.
3. A plain pod with no special settings must still be accepted. Do not delete or scale the workloads.

`kubectl` already points at the cluster as the cluster administrator.
