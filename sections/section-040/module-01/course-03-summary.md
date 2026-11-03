---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Summary

A container is a Linux process that the kernel limits with namespaces, cgroups, capabilities and system-call filters. All containers on a node share one kernel. An application compromise gives the attacker the identity, files, credentials and network paths that the process already has. A container escape needs a weak isolation setting or a kernel flaw, and it gives the attacker the authority of the node.

The inventory of a compromised pod has six entries: the user of the process, its capabilities, its file system, its service account token, its environment and its network reach. Each entry has a matching control: `runAsNonRoot`, `capabilities.drop`, `readOnlyRootFilesystem`, least-privilege roles with `automountServiceAccountToken: false`, fewer Service links and NetworkPolicy. Most entries are normal grants, and they matter only because a compromised process uses them.

Every pod can reach the API server address. The protection is authentication and authorization, not the network path. An inventory covers the cluster configuration. It does not cover vulnerabilities in the image or kernel, nor the data held by the application.

Key facts:

- A privileged container receives all capabilities and host devices.
- A writable root file system lets an attacker store tools in the container.
- A service account token gives the roles of that account and nothing more.
- Pod replacement does not remove a flaw that is in the image.

<!-- astrona:playground:destroy -->
