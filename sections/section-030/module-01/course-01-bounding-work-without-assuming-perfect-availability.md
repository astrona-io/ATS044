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

## Common pitfalls

> [!WARNING]
> Limits and quotas protect different boundaries and do not create capacity. Retries and extra replicas can worsen a dependency bottleneck rather than restore availability.
