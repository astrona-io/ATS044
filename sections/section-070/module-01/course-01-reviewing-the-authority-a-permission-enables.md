---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Reviewing The Authority A Permission Enables

Privilege escalation means gaining authority beyond the intended starting level. In Kubernetes, the route can involve application programming interface (API) grants, workload configuration, credentials or host interfaces. A defensive review should ask what an actor can accomplish with a permission, not only whether the verb sounds narrow.

## Direct And Indirect API Power

Permission to read Secrets can expose credentials for other identities or external systems. Permission to modify roles or bindings can affect future grants within the relevant scope and protections. Permission to create workloads can allow access to mounted data or selected ServiceAccounts when the surrounding policy permits it.

A caller lacking one direct operation may still reach similar data through process execution, a mounted volume or a powerful controller. These paths depend on actual resource and admission rules, so do not claim every Pod creator automatically becomes cluster administrator. The model should identify the available route and the control that limits it.

role-based access control (RBAC) grants combine across applicable bindings. Removing one broad rule does not establish reduced authority if another grant remains. Group membership and cluster-wide bindings can expand scope beyond the namespace an operator first inspected.

## Workload And Host Boundaries

A privileged container, writable host path or exposed runtime socket can weaken the ordinary execution boundary. A process can gain consequential host access through such an interface even when it runs with a non-root user or has no Kubernetes API token. Numeric identity is only one part of the privilege contract.

Required placement on a dedicated node does not eliminate administrative or kernel trust. The host and cluster operators can still have broader authority. Use a stronger management or execution boundary where mutually untrusted workloads require it, while maintaining appropriate permissions within that boundary.

## Controls At Different Stages

Authorization limits requested API actions. Admission can reject dangerous declarations or enforce selected identity and mount policy. Runtime security contexts constrain process privileges and system calls. Network policy narrows supported connections. Each addresses a different part of a possible escalation path.

A policy must also protect its own configuration. An identity able to disable the admission rule or change a security-significant namespace label can weaken the boundary that appears to constrain it. Review authority over controls as well as authority over workloads.

## A Least-Privilege Scenario

A deployment job needs to update one application image. Giving it permissions to change every role, create arbitrary privileged Pods and read all Secrets exceeds that purpose. Narrow the role to intended resources and scope, then use admission and runtime restrictions to limit declarations permitted within the remaining authority.

The resulting grant still has consequences: updating the application image means selecting code that runs with the workload's existing credentials. Source and artifact trust therefore remain necessary even after the Kubernetes role is narrowed. Least privilege reduces blast radius; it does not make compromised code benign.

## Detection And Recovery

Audit records can show sensitive API changes, while runtime evidence can reveal host or process actions beyond the API. Examine the credential and data consequences of the route actually used. Revoking the original token may be insufficient if other grants or credentials were established under its authority.

A complete privilege review traces reachable authority, applicable controls and residual access. This reasoning is more reliable than equating one omitted verb, one non-root setting or one namespace with complete prevention of escalation.

## Common pitfalls

> [!WARNING]
> Effective authority includes indirect data, identity and host paths. A narrow-looking grant, non-root user or missing API token does not independently prove that broader access is impossible.
