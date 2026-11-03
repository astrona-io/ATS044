---
draft: true
exam_objectives:
  - Persistence
---
# Summary

Attacker persistence is any change that outlives the first foothold. In a cluster it is usually an object in the API, not a file in a container. A Deployment, DaemonSet, StatefulSet or CronJob starts new pods from its template, so deleting the pod only triggers reconciliation, and the controller creates the same pod again.

Authority persists in the same way. A RoleBinding, ClusterRoleBinding or long-lived credential keeps working after the first pod is gone. Objects that change what the API accepts, such as mutating admission webhooks and custom resource definitions, can persist the attacker's influence over later workloads.

The search order is workload controllers first, then bindings, then admission configuration. For each object, check the source of truth, the creator and the dependants before you delete it, and save a copy as evidence. Recovery also covers the tools that apply desired state: a compromised Git repository or registry restores the attacker's objects after they were deleted.

Key facts:

- A pod owned by a ReplicaSet comes back after deletion with the same template.
- A CronJob has no pod between runs, so it needs its own search.
- Bindings hold no code but keep authority alive.
- Delete the controller, not the pod.

<!-- astrona:playground:destroy -->
