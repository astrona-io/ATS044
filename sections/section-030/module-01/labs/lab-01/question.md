# Question

Solve this question on: `terminal`

The namespace `outpost` runs `drifter` and has no resource boundary. Add one.

1. Create a ResourceQuota in `outpost` that allows at most 6 pods and caps the total `limits.memory` and `requests.memory`.
2. Create a LimitRange in `outpost` that gives every container a default memory request and a default memory limit.
3. A pod that declares no resources must still be accepted in `outpost`, and it must receive a memory limit.

Do not change the example Deployments.

`kubectl` already points at the cluster as the cluster administrator.
