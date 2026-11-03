---
draft: true
exam_objectives:
  - Kubernetes Trust Boundaries and Data Flow
---
# Tracing Authority Across The Platform

A threat model is a structured account of what can go wrong, how harm can occur and which controls address it. For Kubernetes, start with the assets and data flows rather than a list of product vulnerabilities. The model should describe the actual environment and its trust assumptions.

## Assets, Actors And Entry Points

Assets include application data, application programming interface (API) credentials, image artifacts, cluster configuration and service availability. Actors include users, workloads, operators, build systems and external services. Some actors are intentionally trusted for selected actions, while others supply untrusted input. Trust should be scoped to a responsibility rather than assigned universally to an identity name.

An entry point is a place where an actor can interact with the system: an application endpoint, API server, repository, node agent or administrative workstation. The effect depends on the reachable interface and available authority. A public web input and a runtime management socket are both entry points with very different possible consequences.

A trust boundary is a transition where one set of assumptions or privileges gives way to another. User-to-application, application-to-database, workload-to-API and control-plane-to-node are useful examples. State what authenticates and authorizes the transition and which data becomes trusted afterward.

## Following A Request

The `shuttle` application submits a report request to `probe`. A network connection reaches a gateway or Service. Transport security can verify a peer and encrypt a hop. Application authentication identifies the user or caller. Authorization checks whether that identity may create the report. The backend then writes data through its own database identity.

Each transition can fail differently. An allowed network path does not establish application permission. A valid user credential does not authorize every report. A database role available to `probe` does not mean every incoming request should be allowed to use its full power. The application mediates that authority.

```mermaid
flowchart TB
    U["User or client"] -->|"untrusted request"| A["Application"]
    A -->|"scoped data operation"| D["Database"]
    A -->|"workload credential"| K["Cluster API"]
    O["Operator"] -->|"administrative authority"| K
    K -->|"assigned workload"| N["Node execution"]
```
The same application can cross several boundaries using different identities and permissions.

## Control Plane And Supply Chain

A workload's image originates in a build and repository workflow before a node executes it. Source authors, build credentials and registry publishers therefore participate in the execution trust chain. A compromised build can introduce unwanted behavior without attacking the API server directly.

Cluster administrators and node administrators have powerful positions in the model. A node controller can affect local runtime and plaintext data. A cluster administrator can change workloads and permissions. Namespace isolation depends on these trusted systems, so mutually untrusted tenants may require stronger management or execution boundaries.

## Linking Threats To Controls

For each path, describe a possible misuse and consequence. A stolen deployment credential can create an overly privileged workload. Narrow API grants, admission checks, runtime restrictions and audit records address different stages. A blocked connection can reduce exposure, while rotation and trusted restoration handle a confirmed credential compromise.

Document assumptions such as trusted node hosts, controlled label ownership and an enforcing network implementation. Then identify what changes if an assumption fails. A diagram is useful only when it exposes those relationships and supports concrete control decisions.

## Taking An Inventory In The Playground

A threat model is only useful when it matches the real cluster. The fastest way to check it is to ask the cluster itself. The commands below are read-only, so you can run them in any order. Each one answers one question about assets, actors or entry points.

<!-- astrona:playground:renew -->
List the namespaces first. Each namespace is a scope for names and for most permissions, so it is the first place an inventory of actors starts:

```sh
kubectl get namespaces
```

You should see the namespaces `starfleet` and `outpost` next to the system ones such as `kube-system`. Next, list the identities that workloads can use in `starfleet`:

```sh
kubectl get serviceaccounts -n starfleet
```

Every workload (`scout`, `probe`, `shuttle`) has its own service account, and Kubernetes also creates a `default` service account in each namespace. A pod that names no service account runs as `default`.

The control components are assets too. On a kind cluster they run as static pods in `kube-system`:

```sh
kubectl get pods -n kube-system -o wide
```

You should see the `kube-apiserver`, `etcd`, `kube-controller-manager` and `kube-scheduler` pods on the control-plane node. The API server is the only component that talks to etcd, the key-value store that holds every object. If an attacker reads etcd, the attacker reads every Secret that is not encrypted at rest.

To see what an actor may do, ask the API server what the `shuttle` service account is allowed to do:

```sh
kubectl auth can-i --list --as=system:serviceaccount:starfleet:shuttle -n starfleet
```

The list is short. It shows the discovery rights every authenticated identity receives and nothing that touches Secrets. The list is the actor's authority on the API entry point, and it is the first thing to record in the model.

## What The Inventory Gives You

The commands above produce four lists: namespaces, service accounts, control components and permissions. Put them in one table and add a column that names the trust assumption for each row. For example, a row can say "`shuttle` is trusted to read its own pods, and nothing else". A table like this is the smallest useful threat model, and every later step adds rows to it.

## Taking An Inventory In The Playground

A threat model is only useful when it matches the real cluster. The fastest way to check it is to ask the cluster itself. The commands below are read-only, so you can run them in any order. Each one answers one question about assets, actors or entry points.

List the namespaces first. Each namespace is a scope for names and for most permissions, so it is the first place an inventory of actors starts:

```sh
kubectl get namespaces
```

You should see the namespaces `starfleet` and `outpost` next to the system ones such as `kube-system`. Next, list the identities that workloads can use in `starfleet`:

```sh
kubectl get serviceaccounts -n starfleet
```

Every workload (`scout`, `probe`, `shuttle`) has its own service account, and Kubernetes also creates a `default` service account in each namespace. A pod that names no service account runs as `default`.

The control components are assets too. On a kind cluster they run as static pods in `kube-system`:

```sh
kubectl get pods -n kube-system -o wide
```

You should see the `kube-apiserver`, `etcd`, `kube-controller-manager` and `kube-scheduler` pods on the control-plane node. The API server is the only component that talks to etcd, the key-value store that holds every object. If an attacker reads etcd, the attacker reads every Secret that is not encrypted at rest.

To see what an actor may do, ask the API server what the `shuttle` service account is allowed to do:

```sh
kubectl auth can-i --list --as=system:serviceaccount:starfleet:shuttle -n starfleet
```

The list is short. It shows the discovery rights every authenticated identity receives and nothing that touches Secrets. The list is the actor's authority on the API entry point, and it is the first thing to record in the model.

## What The Inventory Gives You

The commands above produce four lists: namespaces, service accounts, control components and permissions. Put them in one table and add a column that names the trust assumption for each row. For example, a row can say "`shuttle` is trusted to read its own pods, and nothing else". A table like this is the smallest useful threat model, and every later step adds rows to it.

## Common pitfalls

> [!WARNING]
> An internal network or familiar identity is not a universal trust guarantee. Trace each transition's authority and data rather than assuming the entire platform shares one security boundary.
