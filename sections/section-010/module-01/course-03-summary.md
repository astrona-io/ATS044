---
draft: true
exam_objectives:
  - Kubernetes Trust Boundaries and Data Flow
---
# Summary

A threat model starts with assets, actors and entry points. Assets are the data, credentials, images, configuration and availability that can be harmed. Actors are users, workloads, operators and build systems. Entry points are the interfaces an actor can reach, such as an application port, the API server or a node agent.

A trust boundary is a place where the assumptions or privileges change. Each boundary needs a named mechanism that authenticates and authorizes the crossing. A network path alone does not prove identity, and an identity alone does not prove permission for every operation.

Every pod carries a service account token by default. The kubelet mounts it as a projected volume, and any process in the container can read it. A workload that does not call the Kubernetes API should not mount the token, and `automountServiceAccountToken: false` removes it. Removing an entry point is stronger than detecting its misuse.

Key facts:

- Assets, actors and entry points go into one table with a trust assumption per row.
- The API server is the only component that reads and writes etcd.
- `kubectl auth can-i --list --as=...` shows the authority of one actor.
- The token volume is added by admission unless the pod or service account turns it off.

<!-- astrona:playground:destroy -->
