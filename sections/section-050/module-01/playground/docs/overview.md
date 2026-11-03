# Overview: Network Attackers And Peer Trust (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- The Deployment `radar` and a Service `radar` in `starfleet` that clients cannot reach.

## Practice tasks

- Send TLS requests from `shuttle` to the API server with no CA file, with the cluster CA and with a wrong host name, and read each exit code.
- Walk the request path to `radar`: name, endpoints, port and listener.
- Send a request with a custom header to `probe` and read the headers that it echoes.
- Compare the result of `curl --retry` against a `503` response with and without retries.
- Fix `radar` and prove the fix from `shuttle`.
