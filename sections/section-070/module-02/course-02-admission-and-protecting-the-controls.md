---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Admission And Protecting The Controls

Role-based access control decides who may send a request. It does not check what a pod specification asks for. Pod Security Admission checks the content of pods and rejects dangerous settings. This part enforces a level on a namespace, proves it with accepted and rejected requests and then protects the control from change.

## The Levels And The Modes

Pod Security Admission is a built-in admission controller. It applies one of three levels to a namespace.

- `privileged` has no restrictions.
- `baseline` blocks the known routes to privilege: privileged containers, host namespaces, host paths, extra capabilities and a few more.
- `restricted` follows current hardening practice. It also requires a non-root user, no privilege escalation, dropped capabilities and a seccomp profile.

Each level can be applied in three modes, set by labels on the namespace.

- `enforce` rejects a pod that violates the level.
- `audit` allows the pod and adds an audit annotation.
- `warn` allows the pod and returns a warning to the user.

The labels have the form `pod-security.kubernetes.io/<mode>: <level>`. A namespace with no labels uses the cluster default, which in a plain cluster is `privileged`.

## Check The Current State

<!-- astrona:playground:renew -->
Read the labels of the namespace:

```sh
kubectl get namespace starfleet --show-labels
```

The labels show no `pod-security.kubernetes.io` entry, so nothing is enforced. Save this as `risky-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: risky
  namespace: starfleet
spec:
  containers:
    - name: risky
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
      securityContext:
        privileged: true
```

Send it with a server-side dry run:

```sh
kubectl apply -f risky-pod.yaml --dry-run=server
```

The pod is accepted.

## Enforce The Baseline

Label the namespace:

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline
```

Send the same request again:

```sh
kubectl apply -f risky-pod.yaml --dry-run=server
```

The API server rejects the pod with a message that names the violated policy, which is `privileged` containers. Now save a pod that follows the baseline as `plain-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: plain
  namespace: starfleet
spec:
  containers:
    - name: plain
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
```

Send it with a dry run:

```sh
kubectl apply -f plain-pod.yaml --dry-run=server
```

The pod is accepted. A control that rejects everything is as useless as one that rejects nothing, so always prove both results.

## What Enforcement Does Not Do

The label applies to new pods. The pods that already run keep running, even if they violate the level. Deployments continue to hold their pod templates, and a violating template is rejected only when the controller tries to create a new pod. To see which running workloads would violate a level before you enforce it, label the namespace with `warn` and `audit` first, or use a server-side dry run of the label:

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=restricted --dry-run=server --overwrite
```

The command returns a warning for each existing pod that would not satisfy `restricted`. Do not apply `restricted` to the namespace before the workloads are hardened, because the next restart would fail.

## Protect The Control

A control that the attacker can change is not a control. Check these points.

- The right to patch or update `namespaces` lets an identity remove the label. Grant it to administrators only.
- Exemptions in the configuration of the admission controller can exclude users, runtime classes and namespaces. Review the list and keep it short. The namespace `kube-system` is often exempt.
- A policy engine uses webhooks. The right to change a webhook configuration lets an identity disable the check. Treat `validatingwebhookconfigurations` and the policy objects as security-critical.
- Audit the changes to namespace labels and webhook objects, so that a removal shows up.

## Combine The Controls

Pod Security Admission does not replace RBAC, and RBAC does not replace Pod Security Admission. The role limits who may send a request. The admission label limits what the request may ask for. A hardened security context limits what a compromised process can do. A NetworkPolicy limits where it can connect. Each control limits a different step of the route, so the route needs all of them.

Keep a test for each control. A request that must fail and a request that must work document the intended boundary, and a change that breaks the test shows a regression before an attacker does.
