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

## Measure What A Role Really Allows

<!-- astrona:playground:renew -->
The playground gives `shuttle` a Role that is meant to let a release job update Deployments. Read the rules of the Role:

```sh
kubectl get role release-manager -n starfleet -o yaml
```

The rules list `deployments`, `roles`, `rolebindings` and `pods/exec`. Ask the API server what each line means for the service account instead of reasoning from the names:

```sh
kubectl auth can-i patch deployments -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create rolebindings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods/exec -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

All three answers are `yes`. The first is the purpose of the Role. The other two are not. The right to create role bindings changes who holds authority in the namespace, and the right to run commands in a pod reaches the credentials that the pod holds.

## The Verbs That Move Authority

Most verbs act on an object and change that object only. Five cases act on authority itself.

- `create` or `update` on `roles` and `rolebindings` changes what identities may do. The API server stops a caller from granting permissions that the caller does not hold. This check is called escalation prevention. It keeps the caller inside its own authority, but the caller can still hand its own authority to another identity.
- `bind` on a Role or ClusterRole lets the caller create a binding to it without holding its permissions.
- `escalate` on `roles` lets the caller write a role with permissions the caller does not hold.
- `impersonate` on `users`, `groups` or `serviceaccounts` lets the caller send requests as that identity. The caller then holds all authority of the identity.
- `create` on `serviceaccounts/token` mints a token for a service account, so the caller can act as it.

Search the cluster for roles that hold any of these verbs:

```sh
kubectl get roles,clusterroles -A -o json | jq -r '.items[] | select(any(.rules[]?; ((.verbs // []) | map(select(. == "bind" or . == "escalate" or . == "impersonate" or . == "*")) | length) > 0)) | .kind + " " + (.metadata.namespace // "-") + "/" + .metadata.name'
```

Built-in roles such as `cluster-admin` and `system:controller:*` appear, because they need these verbs. A line that you do not recognise needs an owner and a reason.

## Find The Wide Bindings

A binding to `cluster-admin` gives full authority. List the subjects of the bindings that point at it:

```sh
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name=="cluster-admin") | .metadata.name + " -> " + ([.subjects[]? | .kind + "/" + .name] | join(","))'
```

Every line is an identity that holds all authority. Check each subject. A group such as `system:masters` bypasses authorization entirely, and a binding cannot remove its members.

## Common pitfalls

> [!WARNING]
> Effective authority includes indirect data, identity and host paths. A narrow-looking grant, non-root user or missing API token does not independently prove that broader access is impossible.
