---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# From Application Authority To Broader Impact

A vulnerability allows unwanted behavior inside `scout`. The process runs with the application's configured identity, files and network access. That alone can expose important data without escaping the container. A threat model should first examine the authority legitimately available to the process.

## The Initial Boundary

Application compromise can result from unsafe input interpretation, defective authorization or vulnerable dependencies. Defensive code review, input handling and maintained components reduce these causes. Image signatures identify origin, not absence of such defects. A scan detects known issues within its scope, not every possible logic failure.

Once a process is compromised, its read access can disclose mounted credentials and data. Its write access can alter reports or shared files. Its outbound paths can reach permitted dependencies. These are direct effects within the workload's existing authority rather than proof of a kernel escape.

A database credential scoped to one application's tables limits some consequences compared with an administrative database role. A ServiceAccount with no unnecessary application programming interface (API) grant limits cluster actions compared with a broadly privileged one. Least privilege therefore applies to every reachable system, not only Kubernetes role-based access control (RBAC).

## Escalation And Shared Hosts

Container escape means crossing the intended execution boundary into host or other workload authority. Shared-kernel vulnerabilities, privileged configuration and exposed host interfaces can undermine containment. A runtime socket or broad writable host mount can provide powerful access without needing a separate kernel flaw.

Restricted process privileges, system-call filtering, controlled mounts and patched runtime components reduce relevant paths. Stronger sandbox or infrastructure separation can be appropriate for untrusted code. These controls do not repair the original business authorization defect, but they can reduce its broader impact.

## Network And Data Effects

Network segmentation can narrow reachable destinations. It does not stop misuse of a dependency the application must access legitimately. If `scout` may write reports, a compromised process can potentially misuse that permission unless application or data-service controls impose a narrower contract.

Transport encryption protects defined hops but cannot hide plaintext from a process authorized to handle it. A secret in process memory is usable by that process; storage encryption does not make it inaccessible during execution. The trust model must account for where sensitive data becomes plaintext.

## Evidence And Containment

Application logs, runtime observations and API audit records cover different actions. Correlate identities, timing and affected resources without assuming one source captures everything. A missing alert is not proof that no compromise occurred, especially when collection or policy did not observe the relevant behavior.

Contain the identified route and reduce ongoing authority according to the incident scope. Restore reviewed images and configuration, revoke exposed credentials and examine durable data. If host trust was affected, replace or rebuild that execution environment through a trusted process.

## Verifying Recovery

A new Pod can run the same compromised artifact, mount changed data or reuse an exposed credential. Verification should establish trusted inputs, intended permissions, correct user behavior and the relevant external state. Replacement is one operating action, not a complete proof of recovery.

A clear analysis distinguishes initial cause, direct application impact and possible boundary crossing. This lets controls be assessed through the consequences they actually reduce rather than through a vague claim that containers make compromise harmless.

## Reading The Boundary From Inside A Container

A container is a Linux process with limits. The kernel gives it its own view of processes, network and file systems (namespaces), a limit on resources (cgroups), a set of allowed privileges (capabilities) and a filter on system calls (seccomp). The process shares the node's kernel with every other container on the node. The shared kernel is why an escape is a different category of event: it crosses the limits that the kernel itself enforces.

<!-- astrona:playground:renew -->
Run commands inside the `shuttle` pod, as a compromised process would. First read the user and group of the process:

```sh
kubectl exec -n starfleet deploy/shuttle -- id
```

The command prints the numeric user and group IDs. A user ID of `0` is `root` inside the container. Next read the capability set of the main process:

```sh
kubectl exec -n starfleet deploy/shuttle -- sh -c 'grep Cap /proc/1/status'
```

The lines `CapEff` and `CapBnd` hold the effective and bounding sets as hexadecimal masks. A container runtime grants a default set that is smaller than the full set of the node. A container with `privileged: true` receives all capabilities and access to host devices.

Now check whether the container can write to its own root file system:

```sh
kubectl exec -n starfleet deploy/shuttle -- sh -c 'touch /tmp/test-write && echo writable'
```

The word `writable` shows that the process can create files. An attacker uses that to store tools and scripts. The setting `readOnlyRootFilesystem: true` removes this path, and a small writable volume is then mounted only where the application needs it.

## Application Compromise Compared With Escape

The two events have different causes and different effects:

- Application compromise needs a flaw in the application or its dependencies. The attacker receives what the process may already do: read its files, use its credentials and call the services it may call.
- Container escape needs a flaw or a weak setting in the isolation. The attacker receives what the node can do: read the files of other containers, use the credentials of the kubelet and reach the node network.

Most escapes need a precondition: a privileged container, a mounted container runtime socket, a writable mount of a sensitive host path, or a kernel vulnerability that the current kernel version still has. Removing the preconditions is cheaper than predicting the kernel flaw.

## Searching The Cluster For Escape Preconditions

Instead of waiting for an exploit, search the cluster for the settings that make an escape easy. A search over all pods lists those that run privileged, share the host network or process namespace, or mount a host path:

```sh
kubectl get pods -A -o json | jq -r '.items[] | select(.spec.hostNetwork==true or .spec.hostPID==true or any(.spec.volumes[]?; .hostPath != null) or any(.spec.containers[]; .securityContext.privileged==true)) | .metadata.namespace + "/" + .metadata.name'
```

The Starfleet workloads should not appear. System pods in `kube-system`, such as the network plugin and `kube-proxy`, may appear, because they need host access to do their work. Each entry that you did not expect is a question for the owner of the workload. This search takes seconds and finds the setups that turn an application compromise into node access.

## Common pitfalls

> [!WARNING]
> A compromised application can cause serious harm through legitimate access without escaping its container. Pod replacement alone does not restore artifact, credential, host or data trust.
