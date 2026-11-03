# Overview: Sensitive Data Access Paths (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- The Secrets `report-db` and `shuttle-token` in `starfleet`.
- A Role and a RoleBinding that let the service account of `shuttle` read every Secret in `starfleet`.

## Practice tasks

- Decode a Secret with `base64 -d` and explain why that is not decryption.
- Ask `kubectl auth can-i` what `shuttle` may do with Secrets, pods, `pods/exec` and `pods/log`.
- List every Role and RoleBinding that mentions Secrets with `jq`.
- Write a Role that allows `get` on one named Secret and compare the answers of `can-i`.
- Search all pods for containers that take a value from a Secret.
