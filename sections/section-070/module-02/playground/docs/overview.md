# Overview: Preventing Escalation With Controls (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35 with the Starfleet workloads.
- The Role `release-manager`, bound to `shuttle`, with more rights than a release job needs.
- No Pod Security Admission label on `starfleet`.

## Practice tasks

- Replace the Role with one that only allows `get`, `list` and `patch` on Deployments and prove the result with `can-i`.
- Label `starfleet` with `pod-security.kubernetes.io/warn=baseline` and watch the warnings on a risky pod.
- Enforce the baseline and test one rejected pod and one accepted pod with a server-side dry run.
- Preview the `restricted` level with `--dry-run=server` on the label command.
- Find who may update namespaces with `kubectl auth can-i update namespaces --as`.
