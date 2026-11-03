---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Workload Creation And Host Interfaces

The right to create a pod is a right to choose what runs inside the cluster. The pod specification can ask for host access, extra privileges and the credentials of any service account in the namespace. This part shows which fields matter, tests them with a server-side dry run and lists the controls that stop each one.

## What A Pod Specification Can Ask For

The kubelet runs what the specification says, unless a control rejects it. These fields reach beyond the pod.

- `securityContext.privileged: true` gives the container nearly all capabilities of the host and access to its devices.
- `hostPath` volumes mount a directory of the node into the container. A mount of `/` or of the runtime socket gives control over the node and its other containers.
- `hostNetwork`, `hostPID` and `hostIPC` share the network, process and memory namespaces of the node.
- `serviceAccountName` selects the service account whose token the pod receives. A pod can therefore act as any service account in its namespace, whatever the identity of the creator is.
- `capabilities.add` adds Linux capabilities, such as `SYS_ADMIN`, which many escapes need.
- `nodeName` places the pod on a chosen node without the scheduler.

The API server authorises the request to create the pod. It does not check the content for these fields unless an admission control does. A role with `create` on `pods` is therefore not a narrow grant.

## Test The Fields With A Dry Run

<!-- astrona:playground:renew -->
A server-side dry run sends the request through authentication, authorization and admission and does not store the object. Save this as `risky-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: risky
  namespace: starfleet
spec:
  serviceAccountName: scout
  containers:
    - name: risky
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
      securityContext:
        privileged: true
      volumeMounts:
        - name: host
          mountPath: /host
  volumes:
    - name: host
      hostPath:
        path: /
```

Send it as the administrator:

```sh
kubectl apply -f risky-pod.yaml --dry-run=server
```

The command prints `pod/risky created (server dry run)`. The namespace has no admission control that rejects the specification, so a privileged pod with a mount of the node root file system is accepted. Check that nothing was stored:

```sh
kubectl get pod risky -n starfleet
```

The command reports that the pod is not found.

## Who Can Send This Request

Ask the API server whether the service account of `shuttle` may create pods:

```sh
kubectl auth can-i create pods -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The answer is `no`, so `shuttle` cannot start this pod. An identity with `yes` could. The identity would also hold the token of `scout` and could read its Secrets and call the API with its authority. Count the identities with `create` on `pods`, `deployments`, `jobs`, `cronjobs` and `daemonsets`, because each of these creates pods through a controller. A role that cannot create pods but can create a Deployment has the same effect, because the controller creates the pods.

## The Boundary That Remains

A privileged container, a host path or a runtime socket moves the trust boundary from the container to the node. The kernel and the node file system are shared by all pods on the node. An attacker who escapes holds the authority of the node, which includes the credentials of the kubelet and the Secrets of pods on the node. A dedicated node reduces the number of victims and does not remove the trust in the node itself.

When workloads of different trust levels must run in the same cluster, separate them with node pools, namespaces with policies and, when needed, a sandboxed runtime. Each of these is a boundary that you must test.

## Controls At Each Stage

Match each route to the control that stops it.

- Role and binding changes are stopped by narrow RBAC and by removing `bind`, `escalate` and `impersonate`.
- Dangerous pod fields are stopped by admission, such as Pod Security Admission or a policy engine.
- Process privileges are limited by the security context and the seccomp profile.
- Lateral movement is limited by a NetworkPolicy.
- The control itself is protected by limiting who may edit namespace labels, policy objects and webhooks.

## Check Your Understanding

Take the Role `release-manager` and write the effect of each rule in one sentence. A sentence such as "can create a binding to any Role that it holds the permissions of" shows the real reach. If you cannot write the effect, the rule is too broad to review.
