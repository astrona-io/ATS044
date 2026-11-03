---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Summary

By default every pod can reach every other pod. A NetworkPolicy changes that for the pods that it selects, in the directions that it lists. Once a policy selects a pod for ingress or egress, only traffic that some policy allows is permitted in that direction. Policies only add allowed traffic and are combined as a union. Only a network plugin that enforces policies makes them effective, so every policy is proved with a request that must fail and a request that must work.

A default deny uses `podSelector: {}` with no rules and selects every pod in the namespace. Allow rules then name the source, the destination pods and the port. Items of a `from` list are alternatives, and a `podSelector` with a `namespaceSelector` in the same item is an and. The port in a rule is the port of the pod, not the port of the Service. The reply of an allowed connection is allowed without a rule.

Egress rules limit where a compromised pod can send data, and they must allow DNS on port 53 to the cluster DNS pods or names stop resolving. A NetworkPolicy works at the level of addresses and ports. It does not check identity, certificates or paths.

Key facts:

- `podSelector: {}` selects all pods of the namespace.
- A policy with no rules for a direction allows nothing in that direction.
- A `status=000` result from curl means that no response arrived.
- Policies cannot deny, they only allow.

<!-- astrona:playground:destroy -->
