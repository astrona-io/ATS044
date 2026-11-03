---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Network Reachability And Request Evidence

The `shuttle` client cannot reach `probe`. A request path includes name resolution, a Service access point, eligible endpoints, network forwarding and the application listener. Troubleshooting should distinguish these stages before changing unrelated workload settings.

If the name does not resolve, inspect the requested Service name, namespace search behavior and Domain Name System (DNS) reachability. A network policy that blocks DNS can look like a discovery failure. If the name resolves, record what it resolves to and continue testing the connection path conceptually rather than assuming the backend is healthy.

If the Service has no usable endpoints, inspect its selector and Pod readiness. If endpoints exist, check the client-facing port and backend target port. A ready Pod can still be paired with a Service that forwards to the wrong port. The relevant evidence is the application listener and configured mapping.

```mermaid
flowchart TB
    C["Client"] -->|"resolve name"| D["DNS"]
    C -->|"connect"| S["Service address"]
    S -->|"eligible endpoint"| P["Pod address"]
    P -->|"destination port"| A["Application listener"]
```
A successful stage narrows the investigation but does not prove the later stages are working.

Direct backend reachability with failed Service access can implicate selection, forwarding or port mapping. Failures from only one source can implicate that source's routing or egress policy. Failures after a connection succeeds may belong to application behavior, authentication or a downstream dependency.

Preserve the original symptom and verify from the affected client context after correcting a supported cause. Testing from an administrator's machine may use a different namespace, route or policy and therefore cannot establish that the original caller recovered.

## Tracing One Caller Through The Path

Assume `shuttle` in `outpost` uses the short Service name `probe`, but `probe` exists in `starfleet`. That lookup can fail or target another resource before any intended backend connection happens. A correct namespace-qualified name addresses discovery, not a missing listener or blocked network path.

Now assume the correct name resolves to a Service address. Inspect whether its selector finds the intended Pods and whether endpoints are eligible. A Running Pod failing readiness can be excluded from ordinary traffic. A selector with no match yields a different backend problem. Both occur after a successful DNS answer.

If a suitable endpoint exists, check the mapping from client port to destination port. Direct Pod access on the correct port may work while the Service targets another port. That evidence points toward mapping rather than a universal Pod-network failure. Source egress and destination ingress policies can also restrict the connection even with correct discovery and ports.

## Interpreting Transport And Application Results

A refused connection often indicates that the destination can be reached well enough to reject the attempt, but the expected listener is absent or rejecting it. A timeout supports a different set of possibilities, including dropped traffic or an unresponsive dependency. These are clues that need context, not perfect diagnoses by themselves.

An HTTP response moves the investigation further into application or intermediary behavior. Identify which component produced the response; a gateway can return an error without the request reaching the application. A successful TCP connection does not prove application authentication or database access works.

After correction, verify through the original caller's namespace, identity and route. A test from another source can bypass the policy or naming rule that caused the problem. The full request path matters because restoring one stage is useful only when the intended operation can traverse the remaining stages too.

## Running The Checks In The Playground

The playground has a Service `radar` in `starfleet` that clients cannot reach. Work through the stages in order with the client that has the problem, which is `shuttle`.

<!-- astrona:playground:renew -->
Stage 1 is name resolution. Resolve the name from the client pod:

```sh
kubectl exec -n starfleet deploy/shuttle -- sh -c 'curl -sS -m 5 -o /dev/null http://radar/healthz; echo "exit=$?"'
```

The exit code tells the stage that failed. Code `6` means the name did not resolve. Code `7` means the connection was refused. Code `28` means a timeout. Any HTTP status in the output means the connection worked and the application or a proxy answered. Stage 2 is the endpoints of the Service. A Service sends traffic only to ready pods that match its selector:

```sh
kubectl get endpoints radar -n starfleet
kubectl get service radar -n starfleet -o jsonpath='{.spec.selector} {.spec.ports}{"\n"}'
```

An empty `ENDPOINTS` column means that no ready pod matches the selector. Compare the selector with the labels of the pods:

```sh
kubectl get pods -n starfleet --show-labels
```

Stage 3 is the port mapping. The `targetPort` of the Service must be the port on which the container listens. Compare it with the container port:

```sh
kubectl get deployment radar -n starfleet -o jsonpath='{.spec.template.spec.containers[0].ports}{"\n"}'
```

Fix each fault that you find and repeat the request from the same client. The graded task on the next page uses this same fault.

## Verify From The Affected Client

After a fix, run the original request again from `shuttle` and read the exit code and the status. A different client can pass while the affected client still fails, because routes, namespaces and policies can differ. Also check the endpoints list again, because a rollout can change it. A fix is complete when the original symptom is gone for the original caller and when the endpoints show at least one ready pod.

## Reading The Events

When pods do not become ready, Kubernetes records the reason as events. Read the events of the namespace in time order:

```sh
kubectl get events -n starfleet --sort-by=.lastTimestamp
```

Readiness probe failures, image pull problems and scheduling errors appear here. A pod that is not ready is removed from the endpoints of its Service, so an event about readiness often explains an empty endpoints list.

## Common pitfalls

> [!WARNING]
> Name resolution, endpoint selection, connection establishment and application responses are separate checks. Test the caller and path involved in the actual failure.
