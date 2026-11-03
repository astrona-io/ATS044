---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Request Evidence, Timeouts And Retries

When a request fails, or when someone claims that a request was made, a defender needs evidence. When a client retries, the load on the server changes. This part shows what a single request leaves behind, how the client sets timeouts and retries, and why a retried request needs an identifier that the server can use to detect duplicates.

## What A Request Leaves Behind

A request passes the client, the network, optional proxies, the Service address, the pod and the application. Each of them can record something:

- The client records its own exit code or status.
- A proxy or gateway may record the request line, the status and the source address.
- The application may record the request, the user and the result in its log.
- Kubernetes records pod events, restarts and readiness changes.
- The Kubernetes API server records requests to the API in its audit log, if auditing is on.

No single source sees everything. A missing log line is not proof that nothing happened, because the component that handled the request may not log it.

<!-- astrona:playground:renew -->
Send a request to `probe`, which echoes what it receives, and read what the server saw:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -H "X-Request-Id: report-1001" http://probe:8080/headers
```

The reply is a JSON document that lists the headers. It includes `X-Request-Id` with the value you sent. Read the application log of `probe` and check whether it recorded the request:

```sh
kubectl logs -n starfleet deploy/probe --tail=5
```

The log may show the request line with the path and status. If the application does not log requests, the log shows nothing for this call, and the only evidence is on the client side.

## Timing A Request

`curl` can print the status and the time of a request with a write-out format. Run it against `scout`:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -o /dev/null -w 'status=%{http_code} total=%{time_total}\n' http://scout/healthz
```

The status should be `200` and the total time should be a small number of seconds. A client that records both values for every call gives the defender a baseline for a normal request. A slow response that returns `200` is a different symptom than a timeout.

## Timeouts And Retries

A timeout bounds how long the client waits. A retry sends the request again after a failure. The two settings together decide how much extra load a failing dependency receives. If a server is slow, and 100 clients each retry three times without waiting, the server receives 400 requests instead of 100. The extra load can keep it down.

`curl` has retry options that show the mechanism. Ask for a path that does not exist, which returns status `404`, and a path that returns a server error:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://probe:8080/status/503
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 --retry 2 --retry-delay 1 -o /dev/null -w 'status=%{http_code} retries=%{num_retries}\n' http://probe:8080/status/503
```

The first command shows status `503`. The second shows the same status and `retries=2`: the client sent the request three times in total, with a pause of one second between attempts. By default `curl` treats `503` as a transient error and retries it. A client should add random variation to the pause (jitter) and a maximum total time, so that many clients do not retry at the same moment.

## Idempotency

A request is idempotent when sending it several times has the same effect as sending it once. A `GET` request is idempotent. A request that creates a report is not, unless the client sends a stable identifier and the server keeps a record of the identifiers it has handled. If the first request succeeded but the response was lost, the retry would create a second report. The header `Idempotency-Key` is a common convention. It works only when the server implements it. The mesh or the client library can retry, but the application decides whether the retry is safe.

## Putting It Together For A Network Attacker

An attacker who can drop or delay packets can force timeouts. A client with unlimited retries then repeats requests, which amplifies the effect and can duplicate effects at the server. A client with bounded retries, a total deadline, jitter and idempotency keys limits the damage. Evidence from the client and the server side lets a defender reconstruct what happened, because the attacker controls neither log.

## Choosing Settings

Pick the timeout from the slowest normal response, and add a margin. A timeout of five seconds for a call that takes 50 milliseconds hides failures for too long, and a timeout of 50 milliseconds causes false failures during a short pause. Pick the retry count from the cost of an extra request: one or two retries with jitter are usual. Set a total deadline for the whole operation, so retries never run longer than the user waits.

Retry only for errors that can be transient, such as a connection reset, a timeout or `503`. Do not retry `400` or `403`, because the same request fails again and the repeated requests only add load and noise to the logs.

## Recording Evidence For Later

Evidence that is not saved is lost when the pod is replaced. Copy the log of the application to a file before a restart, and record the time, the client, the destination and the result of each test request. When you report the problem, include the exact command and its exit code. A reader can then repeat the request and compare the result, which turns a claim into a checkable fact.

Time is part of the evidence. Pod clocks are synchronised with the node, and the nodes use network time. Compare timestamps from different sources only after you check that the clocks agree.

## Checking A Retry Policy

To review a client, find three values: the timeout of one attempt, the number of attempts and the pause between them. Multiply the first two to find the longest wait for one operation. Compare that result with the time the caller can wait. Then check whether the server side of the operation can detect a duplicate. If either check fails, change the client setting or the server before an incident shows the problem. A client with a missing deadline is the more common finding than a client with too many retries.

## Circuit Breaking

A circuit breaker stops sending requests to a destination after a number of failures, and it tries again after a pause. While the breaker is open, callers fail at once and the destination gets time to recover. Meshes and client libraries provide this behaviour. It complements timeouts and retries, because it limits the total load that a failing dependency receives from all callers together.

## Common pitfalls

> [!WARNING]
> Retrying a non-idempotent request without an idempotency key can duplicate its effect. Also, a log that is empty does not prove that a request never arrived: first check whether the component logs requests at all.
