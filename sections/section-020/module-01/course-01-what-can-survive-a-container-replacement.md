---
draft: true
exam_objectives:
  - Persistence
---
# What Can Survive A Container Replacement

In a threat model, persistence means maintaining unwanted access or behavior after the initial compromise or a restart. It is different from ordinary persistent storage, though stored data can be one mechanism. The defensive question is which changes can survive removing the process that first caused them.

## Resource State Can Outlive A Process

A compromised identity may be able to create another workload or alter a controller template. Deleting the currently suspicious Pod leaves the modified desired state available for reconciliation. The replacement can therefore run the same unwanted image or settings. Inspect controllers and configuration sources rather than treating one deleted instance as the complete scope.

Roles, bindings and credentials can also preserve authority. A changed grant or newly issued credential can remain valid after the original token is revoked. Recovery should examine the access configuration and credential lifecycle supported by the exposed identity's permissions. The actual scope follows its authority, not an assumption that all compromises have the same effect.

A GitOps controller can either help restore trusted intent or reapply compromised intent. If the source repository was changed, a healthy reconciler can continually restore the harmful declaration. The repository, build and registry are part of the recovery boundary as well as the live cluster.

## Stored Data And External Systems

An application with write access can change database records, shared files or object storage. Those changes can survive Pod replacement and image correction. A helper with a writable shared mount may affect the same data even if its own filesystem is disposable.

Replication can copy unwanted changes, while retention and snapshots can preserve evidence or earlier states. Determine which data was affected and whether a suitable recovery point exists. Restoring a current replica is not the same as restoring trustworthy historical content.

External systems can hold credentials, scheduled work or configuration used by the application. Removing a Kubernetes object may not remove those external effects. Incident scope needs the dependencies reachable through the compromised process or identity.

## Node And Management Trust

If compromise reached the host or runtime control path, workload replacement on the same node can inherit an untrusted execution environment. The response may require rebuilding or replacing the node through a trusted process and rotating accessible credentials. A new Pod identifier does not prove the kernel, runtime or mounted files are clean.

Administrative workstations and automation jobs can similarly retain exposed credentials or modified instructions. Restore the authority sources that continue making requests, not only the resources visible at the end of one incident timeline.

## A Defensive Recovery Sequence

Contain the identified access path and preserve useful evidence. Determine the actions possible under the compromised authority. Restore reviewed desired state and trusted artifacts, replace exposed credentials at their issuers and assess durable data changes. Then verify the intended workload and sensitive access paths.

These activities should follow actual evidence and known scope. A broad unexplained reset can destroy records while leaving an external credential valid. A narrow Pod deletion can leave durable changes untouched. The correct response explains why each restored boundary addresses a persistence route identified in the model.

## Common pitfalls

> [!WARNING]
> Pod deletion removes one instance, not every configuration, credential or external effect. A healthy controller can reapply compromised desired state if its source remains untrusted.
