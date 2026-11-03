# Question

Solve this question on: `terminal`

The namespace `starfleet` holds two objects that give an attacker lasting access. Remove them and make the namespace refuse the same mistake later.

1. The service account `ci-runner` has a Secret of type `kubernetes.io/service-account-token`. It never expires. Remove the Secret and keep the service account.
2. The Deployment `node-agent` mounts the node directory `/etc`. Remove it.
3. Make `starfleet` enforce the `baseline` Pod Security level.

The four example Deployments must stay available.

`kubectl` already points at the cluster as the cluster administrator.
