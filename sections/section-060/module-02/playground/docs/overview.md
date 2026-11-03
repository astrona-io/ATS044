# Overview: Limiting And Recovering From Disclosure (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- The Secret `report-db` and a `probe` Deployment that reads `DB_PASSWORD` from it through an environment variable.

## Practice tasks

- Print the environment of `probe` with `kubectl exec` and find the password.
- Move the password to a read-only mounted file with `kubectl patch` and prove the variable is gone.
- Change the Secret and show that a running pod keeps the old environment value.
- Restart the Deployment with `kubectl rollout restart` and show the new value.
- Mark a Secret `immutable: true` and try to change it.
