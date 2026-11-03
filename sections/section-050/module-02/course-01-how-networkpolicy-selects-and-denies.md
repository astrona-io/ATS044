---
draft: true
exam_objectives:
  - Attacker on the Network
---
# How NetworkPolicy Selects And Denies

A cluster network is open by default. The network plugin forwards all pod-to-pod traffic until a policy says otherwise. This part explains the exact rules that decide when a pod becomes restricted, and then builds a default deny for a namespace and proves it with requests.

## The Rules Of Selection

A NetworkPolicy is a namespaced object. It has a `podSelector` that chooses pods in its own namespace, and a list of `policyTypes`, which are `Ingress`, `Egress` or both. Four rules describe the behaviour.

1. A pod that no policy selects accepts all traffic and may send all traffic.
2. When at least one policy selects a pod for `Ingress`, the pod accepts only traffic that some selecting policy allows. The same holds for `Egress`.
3. Policies only add allowed traffic. They are combined as a union, and there is no rule that denies. Adding a second policy can only open more paths.
4. Only the network plugin enforces policies. If the plugin does not support them, the objects exist and have no effect.

An empty `podSelector: {}` selects every pod in the namespace. A policy that selects pods for a direction and lists no rules for it therefore allows nothing in that direction.

## Check The Open State

<!-- astrona:playground:renew -->
Before any policy exists, send a request from `drifter` in `outpost` to `scout` in `starfleet`:

```sh
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://scout.starfleet/healthz
```

The status is `200`. A pod in another namespace reaches a service that it has no reason to use. Confirm that no policy exists:

```sh
kubectl get networkpolicy -A
```

The command reports that no resources were found, apart from any policies of the network plugin itself, which are not NetworkPolicy objects of the user.

## Build A Default Deny

Save this as `networkpolicy-default-deny-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Apply it:

```sh
kubectl apply -f networkpolicy-default-deny-ingress.yaml
```

Then check the result from both clients:

```sh
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://scout.starfleet/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://scout/healthz
```

Both requests fail now. The `curl` command prints `status=000` after five seconds, which means that no HTTP response arrived before the timeout. Traffic inside the same namespace is blocked too, because the policy selects every pod and allows nothing. A default deny is the starting point, and each needed path is added back by its own allow rule.

## What The Network Plugin Does

The API server only stores the object. The network plugin watches NetworkPolicy objects and turns them into rules that the node applies to the pod network interfaces, usually with `iptables`, `nftables` or eBPF programs. This is why the result appears within a few seconds, and why a cluster with a plugin that ignores policies shows no error. The kind cluster in the playground installs Calico for this reason.

## Ingress And Egress

Ingress rules restrict who can send traffic to the selected pod. Egress rules restrict where the selected pod can send traffic. Both matter. An ingress rule on `scout` protects `scout` from any client, including one in a pod that the policy owner does not control. An egress rule on `shuttle` limits what a compromised `shuttle` can reach, even when the destination has no policy. A default deny for ingress alone does not stop a compromised pod from sending data out to the internet.

Egress rules have one extra duty. Name resolution uses DNS, and the DNS server runs as pods in `kube-system`. A default deny for egress blocks DNS queries too. Every egress policy that keeps name lookups working must allow UDP and TCP port 53 to the DNS pods.

## Return Traffic

A NetworkPolicy allows a connection, not single packets. The reply of an allowed connection is allowed without an extra rule. So an ingress rule for `shuttle` to `scout` does not need an egress rule on `scout` for the reply. A new connection that starts from `scout` back to `shuttle` is a different connection and needs its own rule.

## Reading A Policy Back

After you apply a policy, read what the API server stored and how it describes the selection:

```sh
kubectl describe networkpolicy default-deny-ingress -n starfleet
```

The description shows `PodSelector: <none>` for the empty selector, which means all pods, and it lists the policy type `Ingress` with no allowed ingress sources. Reading the description first helps to spot a selector that matches fewer pods than you meant.

## Common pitfalls

> [!WARNING]
> A NetworkPolicy has no effect when the network plugin does not enforce it, and it shows no error. Always prove a policy with a request that must fail and a request that must work.
