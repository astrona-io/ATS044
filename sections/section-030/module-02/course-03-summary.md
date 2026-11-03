---
draft: true
exam_objectives:
  - Denial of Service
---
# Summary

The API server has limited concurrent capacity, and every controller, kubelet and person depends on it. API Priority and Fairness divides that capacity. A FlowSchema classifies requests by identity, verb and resource and the lowest `matchingPrecedence` that matches wins. A PriorityLevelConfiguration gives the level its weight (`nominalConcurrencyShares`) and decides whether a full level queues or rejects with 429. Flows inside a level have separate queues, so one noisy client cannot starve another. Built-in objects must not be edited, and a small `Reject` level for a client the cluster needs creates an outage.

Small requests can cause large work: replicas, per-node DaemonSets, overlapping CronJob runs, retries, unbounded lists, watches and slow webhooks. Caps exist at each point: `concurrencyPolicy`, `activeDeadlineSeconds`, history limits, `backoffLimit`, paginated list requests and webhook timeouts.

A PodDisruptionBudget limits voluntary disruption through the eviction API. It needs more than one replica to allow any eviction and it does not stop crashes or direct pod deletion. Recovery from overload needs spare capacity, so the sum of requests must stay below the capacity of the cluster by at least the size of one node.

Key facts:

- APF limits concurrency and not a rate per second.
- A rejected request carries `Retry-After`, and clients must wait.
- `minAvailable: 1` with one replica blocks all evictions.
- Quotas, APF and budgets each protect a different resource.

<!-- astrona:playground:destroy -->
