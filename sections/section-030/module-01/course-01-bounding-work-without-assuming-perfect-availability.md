---
draft: true
exam_objectives:
  - Denial of Service
---
# Bounding Work Without Assuming Perfect Availability

Denial of service means preventing legitimate use of a system by exhausting or disrupting a required resource. It can result from malicious traffic, accidental overload or faulty configuration. A Kubernetes design needs to consider application programming interface (API) access, node resources, network capacity and application dependencies separately.

## Node Resources And Admission Budgets

central processing unit (CPU) and memory limits constrain selected runtime consumption. CPU throttling can slow work, while exceeding an enforced memory boundary can terminate a process. These controls limit one boundary but can still produce user-visible failure. They should fit measured application demand and expected peaks.

Requests influence placement. Understated requests can allow dense scheduling that later produces contention; excessive requests can make legitimate Pods unschedulable. A quota controls aggregate admitted resource demand or object counts in a namespace. It does not create physical capacity or guarantee every accepted Pod fits.

The cluster also needs resources for kubelet, runtime and system components. Disk exhaustion from logs or writable data can affect workloads beyond the process producing it. Resource management should protect shared host operation as well as individual application containers.

## API And Object Churn

A caller with permitted API operations can still submit excessive requests or create many objects within its authority. API request fairness, rate-related protections and quotas can contribute to availability according to the platform's configuration. Authentication identifies a caller; it does not automatically bound all accepted work.

A malfunctioning controller can continuously issue requests or recreate failing resources. Observing request rates and errors helps distinguish this behavior from ordinary desired-state recovery. Narrow permissions limit some effects, while availability controls address the volume and cost of allowed operations.

## Application And Dependency Overload

An expensive report operation can consume database or worker capacity even when the container remains within its memory limit. Bound input size, work duration and concurrency at the relevant layer. A gateway rate control can reduce incoming pressure, while the application must still make fair and safe decisions about accepted work.

Retries can multiply load. If every caller retries three times when a dependency slows, the original overload can produce much more traffic. Timeouts, backoff and retry budgets help control that amplification. Repeating unsafe writes also risks integrity, so the recovery behavior must fit the operation's semantics.

## Scaling And Spare Capacity

Horizontal scaling adds instances only when the application and dependencies can use them. Node scaling needs suitable infrastructure capacity and time to provision it. A fixed database bottleneck can remain unchanged while more request handlers increase its load.

Spare eligible capacity supports replacement after failure. A fully committed cluster can create replacement Pod objects without finding a place to run them. Distribution across failure domains and a realistic recovery plan are availability protections distinct from normal-path utilization efficiency.

## Interpreting A Capacity Incident

Identify the resource whose demand exceeds usable supply. API errors, Pending Pods, node pressure, queue backlog and application latency indicate different stages. A correction should address the actual limiting component and verify legitimate user behavior after the change.

Limits and quotas reduce selected risks; they are not universal immunity to overload. A useful threat model connects each shared resource to permitted demand, detection and a bounded recovery action.

## Reading Requests, Limits And Quality Of Service

Every container can declare a request and a limit for CPU and memory. The scheduler uses the request to choose a node: it places a pod only on a node whose allocatable capacity, minus the requests already placed there, can hold the new request. The kubelet and the Linux kernel use the limit at run time. A CPU limit throttles the process. A memory limit makes the kernel stop the process with an out-of-memory (OOM) kill when it goes over.

<!-- astrona:playground:renew -->
Read the resources of the `scout` container in the playground:

```sh
kubectl get pods -n starfleet -l app=scout -o jsonpath='{.items[0].spec.containers[0].resources}{"\n"}'
```

The result shows a CPU request of `10m`, a memory request of `32Mi` and a memory limit of `64Mi`. There is no CPU limit, so the container can use idle CPU without throttling. Now read the quality of service (QoS) class that Kubernetes derived from these values:

```sh
kubectl get pods -n starfleet -l app=scout -o jsonpath='{.items[0].status.qosClass}{"\n"}'
```

The class is `Burstable`, because the pod has requests that are lower than its limits. A pod where every container has equal requests and limits gets `Guaranteed`. A pod with no requests and no limits gets `BestEffort`. When a node runs short of memory, the kubelet evicts `BestEffort` pods first, then `Burstable` pods that use more than they requested, and `Guaranteed` pods last.

Next, compare the demand with the supply. The allocatable capacity of the node is what remains after the system reserve:

```sh
kubectl get nodes -o jsonpath='{.items[0].status.allocatable}{"\n"}'
```

The output lists `cpu`, `memory`, `pods` and `ephemeral-storage`. The `pods` value is a limit as well: a node accepts no more pods than that number, whatever their size.

## What Each Control Protects

A request protects the scheduler's plan. A limit protects the node from one container. A quota protects the cluster from one namespace. A pod count limit protects the node's tracking of pods. None of them creates capacity. A cluster whose total requests equal its capacity has no room for a replacement pod, and the pod stays `Pending`.

## When Limits Make A Pod Fail

A limit is a hard edge, so choosing it badly causes the outage that it was meant to prevent. Two cases are common.

A memory limit that is lower than the real peak makes the kernel stop the container. The pod status then shows the last state as `OOMKilled` with exit code 137, and the kubelet restarts the container with a growing delay (`CrashLoopBackOff`). Read it with:

```sh
kubectl get pods -n starfleet -l app=scout -o jsonpath='{.items[0].status.containerStatuses[0].lastState}{"\n"}'
```

For a healthy pod the field is empty. A CPU limit that is lower than the real demand does not stop the container. It slows it, because the kernel pauses the process for part of each scheduling period. A slow service can fail its health probe and be restarted, which looks like a crash even though no memory limit was hit.

A request that is too high has a different cost. The scheduler reserves the amount whether the pod uses it or not, so large requests make nodes look full while they idle. A new pod then stays `Pending` with the event `Insufficient cpu` or `Insufficient memory`. To read that reason:

```sh
kubectl get events -n starfleet --field-selector reason=FailedScheduling
```

An empty result means no pod has failed to schedule. These three symptoms, `OOMKilled`, throttling and `Pending`, are the signs to look for when resource settings are wrong.

## Common pitfalls

> [!WARNING]
> Limits and quotas protect different boundaries and do not create capacity. Retries and extra replicas can worsen a dependency bottleneck rather than restore availability.
