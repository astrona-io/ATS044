# Overview: Trust Boundaries And Request Data Flow (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`, with no Role, no RoleBinding and no NetworkPolicy of your own.

## Practice tasks

- Send requests to the API server from `shuttle` with no token, with its token and to `/version`. Name the stage that refused each one.
- Use `--dry-run=server` to test a create request as the administrator and as `shuttle`.
- Send a request from `drifter` to `probe` and `scout` in `starfleet`. Find the source address in the response.
- Create a Role that lets `shuttle` read one ConfigMap and test the other ConfigMaps with `can-i`.
