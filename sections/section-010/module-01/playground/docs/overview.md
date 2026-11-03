# Overview: Assets, Actors And Entry Points (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`. Each runs on its own service account and mounts the default token.

## Practice tasks

- Build a table of assets, actors and entry points for the cluster from `kubectl` output only.
- Read the token file from the `shuttle` container and decode its middle part with `base64 -d` to see the claims.
- Check what each service account can do with `kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<name>`.
- Remove the token mount from `drifter` and check that the directory is gone.
- List every pod that sets `hostNetwork`, `hostPID` or a `hostPath` volume.
