---
draft: true
exam_objectives:
  - Denial of Service
---
# Amplification And Recovery Capacity

A denial of service does not need a large attack. In a cluster, one small request can cause a large amount of work, and the work can be repeated forever by a controller that retries. This part shows where that amplification happens, which settings cap it, and how to keep enough capacity so that the application survives a planned disruption.

## Where One Request Becomes Many

- A Deployment with `replicas: 500` creates a ReplicaSet, 500 pods, 500 scheduling decisions and 500 image pulls from one API call.
- A DaemonSet creates one pod per node. A cluster with 200 nodes receives 200 pods from one object.
- A CronJob starts a Job on every schedule time. If a run takes longer than the interval and nothing prevents it, runs pile up, each using resources.
- A Job that fails is retried up to `backoffLimit` times, and each retry is a new pod.
- A list request for all objects of a kind, without a `limit`, makes the API server read and serialise every object. Many clients doing this together cause memory pressure.
- A watch holds a connection open and receives every change. Many watchers make each write more expensive.
- An admission webhook is called for every request that it matches. A slow webhook slows the whole API, and a webhook that fails and is set to `failurePolicy: Fail` blocks the matching requests.

## Capping The Amplification

A CronJob has three fields that limit its growth. `concurrencyPolicy: Forbid` skips a new run when the previous one is still active. `activeDeadlineSeconds` in the Job template stops a run that takes too long. `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` limit how many old Jobs stay in the cluster.

<!-- astrona:playground:renew -->
Check what a dry run of such a CronJob looks like without creating it:

```sh
kubectl create cronjob report -n starfleet --image=curlimages/curl:8.22.0 --schedule="*/5 * * * *" --dry-run=client -o yaml
```

The output has no `concurrencyPolicy` line, so the default `Allow` applies: runs may overlap. Add the field in the file or with `kubectl patch` on a real object. For a list request, ask for a page instead of all objects:

```sh
kubectl get pods -A --chunk-size=50
```

With `--chunk-size`, `kubectl` sends several requests that each carry a `limit` and reads the `continue` token, so the API server never builds one huge response. The default chunk size of `kubectl get` is 500, which is already paginated. A custom client has to set `limit` itself.

## Voluntary And Involuntary Disruption

Not all loss of capacity is an attack. A node upgrade drains the node, and the eviction of each pod is a voluntary disruption. A node crash or an out-of-memory kill is an involuntary disruption. A PodDisruptionBudget (PDB) limits only voluntary disruptions. When an eviction would take the number of available pods below the budget, the API server refuses the eviction with status 429 and the drain waits.

A PDB selects pods with a label selector and states `minAvailable` or `maxUnavailable`. It protects nothing if the Deployment has a single replica: with `minAvailable: 1` and one pod, no eviction is ever allowed and a drain blocks forever. A budget needs at least two replicas to be useful.

## Build A Budget

Scale `probe` to two replicas so that one can be evicted while the other serves:

```sh
kubectl scale deployment/probe -n starfleet --replicas=2
kubectl rollout status deployment/probe -n starfleet
```

Save the budget as `probe-pdb.yaml`:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: probe-pdb
  namespace: starfleet
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: probe
```

Apply it and read its status:

```sh
kubectl apply -f probe-pdb.yaml
kubectl get pdb probe-pdb -n starfleet -o jsonpath='{.status.currentHealthy} {.status.desiredHealthy} {.status.disruptionsAllowed}{"\n"}'
```

With two healthy pods and a minimum of one, the line should read `2 1 1`: one pod may be evicted at a time. Scale `probe` back to one replica and read the line again. The allowed disruptions fall to `0`, which shows why one replica makes the budget block every eviction.

## Capacity To Recover

A system that runs at full capacity cannot recover. When a node fails, its pods need room on other nodes. When a rollout runs, a Deployment needs room for the new pods next to the old ones. Keep the sum of requests below the sum of allocatable capacity by at least the size of the largest node, and keep the number of replicas high enough that a pod loss is not a loss of service.

Recovery steps for an overloaded cluster, in order:

1. Stop the source of load: scale down or delete the runaway workload, or give its identity a small APF level.
2. Remove pods that are stuck and still hold resources, such as `Pending` pods that count against a quota.
3. Restore replicas of the important workloads one at a time, and watch the node capacity as they start.
4. Add or restore a quota or a limit range so the same workload cannot grow again.

## Common pitfalls

> [!WARNING]
> A PodDisruptionBudget does not protect against crashes or against a `kubectl delete pod`. It applies only to the eviction API. Also a budget with `minAvailable` equal to the replica count blocks every node upgrade.
