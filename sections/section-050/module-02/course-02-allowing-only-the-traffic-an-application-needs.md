---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Allowing Only The Traffic An Application Needs

A default deny protects the namespace but also stops the application. The next step is to describe each legitimate path as an allow rule. This part writes rules that select the source by pod label and by namespace, restricts the destination port and keeps DNS working, and tests the result with allowed and blocked requests.

## Anatomy Of An Allow Rule

An `ingress` rule has `from` and `ports`. The `from` list holds peers. Each peer is one of `podSelector`, `namespaceSelector` or `ipBlock`. Peers in the list are alternatives: traffic that matches any one peer is allowed. Inside one peer, a `podSelector` together with a `namespaceSelector` is an `and`: the pod must match both. This difference is a common cause of rules that allow too much.

```yaml
# Two separate peers (or): any pod labelled app=shuttle in this namespace, OR every pod in outpost
from:
  - podSelector:
      matchLabels:
        app: shuttle
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: outpost
```

Remove the dash in front of `namespaceSelector` and the peer becomes one item: pods labelled `app=shuttle` that are in the namespace `outpost`. The namespace label `kubernetes.io/metadata.name` is set by Kubernetes on every namespace, so it can select a namespace by name.

## Allow shuttle To Reach scout

<!-- astrona:playground:renew -->
Make sure a default deny exists in `starfleet`, with `podSelector: {}` and the policy type `Ingress`. Then save this as `networkpolicy-allow-shuttle-to-scout.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-shuttle-to-scout
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: scout
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 9898
```

Apply it:

```sh
kubectl apply -f networkpolicy-allow-shuttle-to-scout.yaml
```

Then test the three paths:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://scout/healthz
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://scout.starfleet/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://probe:8080/get
```

The first request returns status `200`. The second and the third print `status=000`: `drifter` is not in the `from` list, and `probe` has no allow rule at all. The port in the policy is the port on which the pod listens, `9898`, and not the port `80` of the Service. The plugin matches packets after the Service address is translated to the pod address.

## Allow A Whole Namespace

To allow every pod of one namespace, use a `namespaceSelector` alone. Save this as `networkpolicy-allow-outpost-to-probe.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-outpost-to-probe
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: outpost
      ports:
        - protocol: TCP
          port: 8080
```

Apply it and test from `drifter`:

```sh
kubectl apply -f networkpolicy-allow-outpost-to-probe.yaml
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://probe.starfleet:8080/get
```

The status is now `200`, while `drifter` still cannot reach `scout`. Policies are additive and each one names its own destination pods.

## Keep DNS Working With Egress Rules

An egress policy needs a rule for DNS, or no name resolves. Allow queries to the pods that serve the cluster DNS, which carry the label `k8s-app=kube-dns` in `kube-system`:

```yaml
egress:
  - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: kube-system
        podSelector:
          matchLabels:
            k8s-app: kube-dns
    ports:
      - protocol: UDP
        port: 53
      - protocol: TCP
        port: 53
```

The peer above has both selectors in one item, so it matches only the DNS pods. If the lookup fails after you add an egress deny, the exit code of `curl` is `6`, which points at name resolution and not at the destination.

## Review The Set

List the policies and read what each selects:

```sh
kubectl get networkpolicy -n starfleet
kubectl describe networkpolicy allow-shuttle-to-scout -n starfleet
```

The description lists the selected pods and the allowed sources in plain words. Review a set of policies as a table: for each destination, which sources and ports are allowed. A destination that has no row is blocked. A policy tool cannot tell which rows are needed, so the application owner confirms the list.

## What A NetworkPolicy Does Not Do

It works at the IP address and port level. It does not check a certificate, a user or an HTTP path. A source that is allowed can send any request to the allowed port. A service mesh or an application check adds those properties. A NetworkPolicy also does not stop traffic from a pod that runs with host networking, because such a pod uses the address of the node.

## Common pitfalls

> [!WARNING]
> A dash in front of `namespaceSelector` makes it a separate peer, and the rule allows far more than intended. Check each rule with a request from a client that must be blocked.
