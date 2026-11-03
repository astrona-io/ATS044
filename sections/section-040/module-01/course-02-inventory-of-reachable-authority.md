---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Inventory Of Reachable Authority

After a compromise, the first question for a defender is what the attacker can now do. The answer is a list of everything the process can read, call or write. This part builds that list for the `shuttle` pod in four steps: credentials, environment, mounts and network. The same list shows which control would remove an entry.

## Credentials Mounted Into The Pod

A pod that uses a service account receives a projected token file in the container. Any process in the container can read it. Check which files exist in the standard location:

<!-- astrona:playground:renew -->
```sh
kubectl exec -n starfleet deploy/shuttle -- ls /var/run/secrets/kubernetes.io/serviceaccount
```

The listing shows `ca.crt`, `namespace` and `token`. The token proves the identity `system:serviceaccount:starfleet:shuttle` to the API server. What it can do depends on the roles bound to that account. Test it from outside with impersonation:

```sh
kubectl auth can-i --list --as=system:serviceaccount:starfleet:shuttle -n starfleet
```

The list shows the resources and verbs that the account may use. A short list such as `selfsubjectreviews` means the token gives the attacker almost nothing in the API. The field `automountServiceAccountToken: false` in the pod specification removes the file from workloads that never call the API.

## Environment And Service Discovery

Kubernetes writes environment variables into every container for each Service that exists in the namespace when the pod starts. Read them:

```sh
kubectl exec -n starfleet deploy/shuttle -- env
```

The output contains variables such as `SCOUT_SERVICE_HOST` and `PROBE_SERVICE_PORT`. These variables tell a process where its neighbours are without a DNS lookup. Secrets that an application receives as environment variables appear in the same list, so any code in the process can read them. A secret in a mounted file with restrictive permissions is not exposed to a child process by inheritance, but the same process can still open the file.

## Network Reach

By default, a pod can send traffic to every other pod and Service in the cluster, and to the outside world if the node allows it. Test two destinations from the `shuttle` pod:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://scout/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://probe:8080/get
```

Both commands return a response body, which shows that `shuttle` can reach both backends although it may need only one. Now test the Kubernetes API from inside the pod:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -sk -m 5 https://kubernetes.default.svc/version
```

The API server answers the version request. Every pod can reach the API server address, so the protection is the authentication and the authorization of the request, not the network path.

## Putting The Inventory Together

For `shuttle` the inventory has these entries.

| Item | What the attacker gets | Control that limits it |
| --- | --- | --- |
| Process user | A non-privileged or root user inside the container | `runAsNonRoot`, `runAsUser` |
| Capabilities | The default set of the runtime | `capabilities.drop: ["ALL"]` |
| File system | A writable root file system | `readOnlyRootFilesystem: true` |
| Service account token | The roles of `shuttle` in the API | Least-privilege roles, `automountServiceAccountToken: false` |
| Environment | Names and ports of neighbouring Services | Fewer Services in the namespace, `enableServiceLinks: false` |
| Network | All pods and Services in the cluster | NetworkPolicy with egress rules |

The table shows that most of these entries are not exploits. They are normal grants that become dangerous only when the process is compromised. This is why the review of each grant should ask what an attacker could do with it, not only what the application needs it for.

## Reducing Service Links

Kubernetes can skip the variables for Services. The field is `enableServiceLinks: false` in the pod specification. DNS still works, because applications can use the name `scout` without the variables. Removing the variables reduces the information that a process gets for free, although an attacker can still list names with DNS queries against the namespace. It is a small gain, so treat it as a tidy-up and not as a boundary.

## What An Inventory Cannot Show

The inventory covers what the pod specification and the cluster configuration allow. It does not show a vulnerability in the image or the kernel. It does not show data that the application itself holds, such as a database password in a configuration file inside the image. Add a review of the image content and of the external systems that the credentials open, or the inventory understates the impact.

## A Worked Example Of The Chain

Suppose an attacker can run one command through a flaw in `shuttle`. The attacker reads the environment and learns the names of `scout` and `probe`. The attacker calls both from inside the pod, because the network allows it. The attacker reads the service account token and calls the API with it, but the roles of `shuttle` are small, so the call is refused. The attacker writes a tool to `/tmp`, because the root file system is writable, and runs it with the default capabilities.

Each step uses one entry of the inventory. A control that removes one entry breaks one step. For example, a NetworkPolicy that allows `shuttle` to reach only `scout` removes the call to `probe`. A read-only root file system removes the written tool. The aim is not a single perfect control. It is a chain where each step needs something that the pod no longer has.

## Reading The Mounts

List the volumes that the pod mounts and their sources, because a mount can give access to data that the image never contained:

```sh
kubectl get pod -n starfleet -l app=shuttle -o jsonpath='{.items[0].spec.volumes}{"\n"}'
```

For `shuttle`, the list holds only the projected service account token volume. A pod with a `hostPath`, a `secret` or a `persistentVolumeClaim` volume gives the process access to that data. Check the matching `volumeMounts` for `readOnly: true`, because a read-only mount stops writes but not reads.

## Common pitfalls

> [!WARNING]
> Do not treat a read-only token list as proof of safety. A token with no API permissions can still be a valid identity for a database, a mesh or a cloud service that trusts the cluster. Also, `kubectl auth can-i --as` shows RBAC only, not what an external system allows.
