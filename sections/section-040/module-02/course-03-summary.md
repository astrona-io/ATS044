---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Summary

A `securityContext` removes the easy next steps of an attacker. A non-root numeric user, `allowPrivilegeEscalation: false`, dropped capabilities, a read-only root file system and the default seccomp profile each remove one option. They do not remove the application flaw. Pod Security Admission applies a level (`privileged`, `baseline` or `restricted`) to a namespace by label in the modes `warn`, `audit` and `enforce`, so teams can find failing workloads before they enforce.

A suspected compromise is handled in this order: isolate, collect evidence, replace, verify. A NetworkPolicy with no rules for a direction blocks that direction for the selected pods and needs a plugin that enforces it. Evidence includes the pod specification, logs, events, the image digest and audit records. Deleting the pod first destroys the evidence and does not remove a flawed image or stolen credential.

Recovery needs trusted inputs: an approved image digest, reviewed configuration, rotated credentials and minimal roles. If the node was exposed through a host path, socket or privileged mode, the node itself must be rebuilt.

Key facts:

- A numeric `runAsUser` is needed when the image names its user.
- A tag can move, a digest cannot.
- An isolating policy must be tested with a real request.
- A restart does not prove recovery.

<!-- astrona:playground:destroy -->
