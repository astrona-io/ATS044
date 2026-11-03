---
draft: true
exam_objectives:
  - Denial of Service
---
# Summary

Denial of service in a cluster comes from shared resources: node CPU and memory, the number of pods a node accepts, storage and API capacity. A request tells the scheduler how much a container needs and decides placement. A limit is enforced on the node: a CPU limit throttles and a memory limit ends the process with an out-of-memory kill. The pair of values gives each pod a quality of service class: `Guaranteed`, `Burstable` or `BestEffort`, and the kubelet evicts in the reverse order under memory pressure.

A ResourceQuota caps a namespace in total, for compute and for object counts, and the API server rejects a request that would exceed it. When a quota covers CPU or memory, every pod must declare those values. A LimitRange supplies defaults, minimums and maximums per container, and its defaults are added before the quota check.

Quotas and limits bound demand. They do not create capacity. A cluster that is fully committed has no room for a replacement pod, and the pod stays `Pending`.

Key facts:

- Requests drive scheduling and limits drive enforcement.
- A pod with no requests and no limits is `BestEffort` and is evicted first.
- A Deployment passes a quota check, and the pods created from it are refused one by one.
- A LimitRange removes the need for every pod to declare resources.

<!-- astrona:playground:destroy -->
