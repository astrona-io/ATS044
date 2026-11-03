# Question

Solve this question on: `terminal`

The service account `batch-importer` in `starfleet` sends bursts of API requests. Give it its own small pool, and protect `probe` against too many voluntary evictions.

1. Create a PriorityLevelConfiguration named `importer-limited`. It must be of type `Limited`, have `nominalConcurrencyShares` of 5 and reject requests when the pool is full.
2. Create a FlowSchema named `importer-flow` that sends all requests of the service account `batch-importer` in `starfleet` to that level. Use a `matchingPrecedence` of 5000 and distinguish flows by user.
3. Create a PodDisruptionBudget for the pods with the label `app=probe` that keeps at least one pod available. `probe` already runs two replicas.

`kubectl` already points at the cluster as the cluster administrator.
