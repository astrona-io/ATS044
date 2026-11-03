---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Summary

A role should grant the verbs and objects that the task needs. For a release job that sets an image, that is `get`, `list` and `patch` on `deployments` in the group `apps`. Surplus rights on roles, bindings, `pods/exec` and Secrets open routes to broader authority. Replacing the `rules` list removes the old rules, and `kubectl auth can-i --list --as=...` proves the effective result. Wildcards and cluster-wide bindings reach more than intended.

Pod Security Admission checks the content of pods. The levels are `privileged`, `baseline` and `restricted`, and the modes are `enforce`, `audit` and `warn`, set by labels on the namespace. The baseline rejects privileged containers, host namespaces and host paths. Enforcement applies to new pods only, so existing pods keep running. A server-side dry run of a label shows which existing pods would violate a level.

The controls need protection. Only administrators should change namespace labels, admission exemptions, webhook configurations and policy objects. Test each control with a request that must fail and a request that must work.

Key facts:

- `--dry-run=server` runs admission and does not store the object.
- `enforce` rejects and `warn` and `audit` only report.
- The label form is `pod-security.kubernetes.io/<mode>: <level>`.
- Updating a namespace can remove the label.

<!-- astrona:playground:destroy -->

<!-- astrona:playground:destroy -->
