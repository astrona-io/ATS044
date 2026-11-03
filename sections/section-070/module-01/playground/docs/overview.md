# Overview: Privilege Escalation And Indirect Authority (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- The Role `release-manager` and its binding to the service account of `shuttle`. The Role grants rights on Deployments, roles, role bindings and `pods/exec`.
- No Pod Security Admission label on `starfleet`.

## Practice tasks

- Ask `kubectl auth can-i --list --as` what `shuttle` may do and write the effect of each line.
- Search all Roles and ClusterRoles for `bind`, `escalate`, `impersonate` and `*`.
- List the subjects of every binding to `cluster-admin`.
- Send a privileged pod with a `hostPath` volume with `--dry-run=server` and confirm that the cluster accepts it.
- Compare `create` on pods with `create` on Deployments and Jobs.
