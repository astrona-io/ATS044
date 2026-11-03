---
draft: true
exam_objectives:
  - Persistence
---
# Summary

Credentials persist by lifetime. A bound service account token comes from the TokenRequest API, carries an expiry and stops working with its pod. A legacy token Secret of type `kubernetes.io/service-account-token` has no expiry and works until the Secret or the service account is deleted. Search all namespaces for the second kind and replace each consumer with a short-lived token. Client certificates have no revocation, so their expiry is the only limit.

Host access persists by location. A `hostPath` volume mounts node files into a pod, and writes stay on the node after the pod is deleted. Mounts of paths such as `/etc`, `/var/lib/kubelet` or the container runtime socket give the pod control over the node and over other pods. The baseline Pod Security level forbids host paths, host namespaces and privileged containers for new pods in a labelled namespace, and it does not remove running pods.

When a node was reachable by an untrusted pod, the recovery is to replace the node from a trusted image and rotate every credential the node held.

Key facts:

- A token without an `exp` claim never expires.
- Deleting a legacy token Secret invalidates the token.
- Host path writes outlive the pod.
- Replace the node, do not clean it.

<!-- astrona:playground:destroy -->
