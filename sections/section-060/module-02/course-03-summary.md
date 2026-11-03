---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Summary

A Secret reaches a container as an environment variable or as a mounted file. An environment variable is visible to any command that prints the environment and to child processes, and it never changes while the container runs. A file is read only by a process that opens it, it has a mode, and the kubelet updates it when the Secret changes unless it is mounted with `subPath`. A file is the better default. Setting `automountServiceAccountToken: false` removes the API token from a pod that never calls the API.

A rotation creates the new value at the issuer, stores it in the Secret, makes the consumers use it and revokes the old value. Changing only the Secret rotates nothing, because the issuer still accepts the old value and a running pod keeps the old environment variable. A rollout restart makes the pods read the Secret again. An immutable Secret cannot change, so a new value needs a new Secret name and a rollout.

Revocation stops later use of the old value. It does not undo use during the window of risk and does not remove a copy that was already read. The records of the issuer show what the credential did. A rotation that is practised when nothing is wrong is fast and safe during an incident.

Key facts:

- `kubectl rollout restart` makes pods read the Secret again.
- `readOnly: true` and `defaultMode: 0400` limit the mounted file.
- An environment variable does not change while the container runs.
- Revocation recovers future access and not past disclosure.

<!-- astrona:playground:destroy -->

<!-- astrona:playground:destroy -->
