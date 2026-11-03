# Question

Solve this question on: `terminal`

Three weaknesses let one workload or one client use up shared capacity. Close all of them.

1. The namespace `outpost` has no boundary. Add a ResourceQuota that allows at most 6 pods and caps `requests.memory` and `limits.memory`. Add a LimitRange with a default memory request and a default memory limit, so pods that declare nothing are still admitted and receive a limit.
2. The service account `report-exporter` in `starfleet` floods the API server. Create a PriorityLevelConfiguration `exporter-limited` of type `Limited` with `nominalConcurrencyShares` of 5 and a rejecting response. Create a FlowSchema `exporter-flow` that sends all requests of that service account to it with a `matchingPrecedence` of 5000.
3. Create a PodDisruptionBudget for `app=probe` with `minAvailable: 1`. `probe` already runs two replicas.

`kubectl` already points at the cluster as the cluster administrator.
