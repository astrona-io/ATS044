# Question

Solve this question on: `terminal`

The Deployment `drifter` in `outpost` runs its container with the defaults of the image. Reduce what a compromised process in this container could do.

1. The process must run as a non-root numeric user. Use the user ID `10001`, because the image names its user and `runAsNonRoot` needs a number.
2. The process must not be able to gain extra privileges, and all Linux capabilities must be dropped.
3. The root file system must be read-only.
4. The pod must keep running with its existing command.

`kubectl` already points at the cluster as the cluster administrator.
