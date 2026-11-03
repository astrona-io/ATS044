---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Summary

A Secret stores each value as base64, which is encoding and not encryption. Anyone who can read the object can decode the value. The verbs `get`, `list` and `watch` on `secrets` read values, and `list` returns every Secret in the namespace. A rule with `resourceNames` and only `get` limits a role to named objects. A Role works in its own namespace, and a ClusterRoleBinding reaches every namespace.

Indirect routes give the same data. The `create` verb on `pods/exec` runs a command in a container, so the command prints environment values and mounted files. The `create` verb on `pods` lets an identity start a pod that mounts any Secret of the namespace. The `get` verb on `pods/log` reads whatever the application printed. The API server checks the verbs of the request and not the effect of the container.

Encryption at rest protects the stored database and not an authorised reader. Copies of a value live in logs, audit bodies, backups, images and source history. Deleting the Secret object does not remove them. The review lists every copy and every reader and removes each one without a reason.

Key facts:

- `kubectl auth can-i --list --as=...` shows what an identity may do.
- `list` on `secrets` gives the value of every Secret in the namespace.
- Pod creation and exec are indirect readers of Secrets.
- An audit level of `Metadata` keeps values out of the audit log.

<!-- astrona:playground:destroy -->

<!-- astrona:playground:destroy -->
