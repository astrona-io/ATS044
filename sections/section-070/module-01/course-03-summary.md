---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Summary

The name of a verb does not show its reach. The API server answers what an identity may do, and `kubectl auth can-i` with `--as` shows the real result. The verbs `create` and `update` on roles and bindings, `bind`, `escalate`, `impersonate` and `create` on `serviceaccounts/token` change who holds authority. Escalation prevention stops a caller from granting more than it holds, but the caller can still pass on what it holds. A binding to `cluster-admin` and the group `system:masters` give full authority.

The creation of a pod, or of a controller that creates pods, chooses what runs in the cluster. The specification can request privileged mode, host paths, host namespaces, extra capabilities and the token of any service account in the namespace. The API server authorises the request and does not check these fields unless an admission control does. A server-side dry run tests the request without storing the object.

Each route has a control. RBAC limits the verbs, admission rejects dangerous declarations, the security context limits process privileges, a NetworkPolicy limits connections and restricted access to labels and policy objects protects the controls themselves.

Key facts:

- `create` on `pods` is not a narrow grant.
- A Deployment or a Job creates pods, so its creator has the same reach.
- `bind`, `escalate` and `impersonate` move authority.
- `--dry-run=server` runs admission without storing the object.

<!-- astrona:playground:destroy -->

<!-- astrona:playground:destroy -->
