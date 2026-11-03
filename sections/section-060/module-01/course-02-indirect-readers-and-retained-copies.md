---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Indirect Readers And Retained Copies

A person who cannot read a Secret may still reach its value by another allowed operation. This part lists those indirect routes, tests them with permission checks and then follows the value into logs, backups and other copies that outlive the Secret.

## Routes That Do Not Use The Secret Verb

The value of a Secret reaches a pod in one of two ways. Either Kubernetes injects it as an environment variable, or it mounts it as a file. In both cases the process in the container holds the plain value. Any identity that can run a command in that container can read it. Four operations give indirect access.

1. Exec. The `create` verb on the subresource `pods/exec` runs a command in a container. The command `env` prints the environment variables and `cat` reads the mounted files.
2. Pod creation. An identity that can create pods in a namespace can create a pod that mounts any Secret of that namespace and prints it. The pod needs no `get` permission on the Secret, because the kubelet delivers the value to the container.
3. Logs. The `get` verb on `pods/log` reads what the application printed. A program that prints its settings at start up has written the value to the log.
4. Port forward and proxy. These reach the application, which may return data that it should not.

The API server checks the verbs of the request, and not the effect of the container that the request creates. A role that grants `create` on `pods` is therefore close to a role that reads every Secret in the namespace.

## Test The Routes

<!-- astrona:playground:renew -->
Check what the service account of `shuttle` may do with pods:

```sh
kubectl auth can-i create pods/exec -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get pods/log -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

Each answer is `no`. The only route of `shuttle` to the data is the direct Secret rule that you found earlier. Compare this with the administrator, who holds all four routes:

```sh
kubectl auth can-i create pods/exec -n starfleet
```

The answer is `yes`. Now list every permission of `shuttle` in the namespace:

```sh
kubectl auth can-i --list -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The list shows `secrets` with the verbs `get`, `list` and `watch`. Read each line and ask which indirect route it opens. A line for `pods/exec`, `pods` with `create`, or a wildcard in the resource column would open another route.

## What An Authorised Reader Receives

Read the Secret as the administrator, and note that a normal request returns the value in plain text:

```sh
kubectl get secret shuttle-token -n starfleet -o jsonpath='{.data.token}' | base64 -d; echo
```

Encryption at rest protects the stored data in the cluster database, so that someone who steals a disk or a database file does not read the values. The API server decrypts the value before it answers an authorised request. Encryption at rest therefore does not stop an authorised reader, and it does not stop an identity with a broad role. Roles decide who is authorised, so the roles are the main control.

## Copies Outside The Secret

A value can leave the Secret in several ways. Check each of them in a real system.

- Logs. An application that logs its settings or an error with the connection string writes the value into the log files. The log system has its own readers, which are often more people than the readers of the Secret.
- Audit records. An audit policy at the level `Request` or `RequestResponse` records the body of a request. A request that creates a Secret then writes the value into the audit log. The level `Metadata` records who made the request and not the body, so use it for Secrets.
- Backups and snapshots. A backup of the cluster database holds every Secret at the time of the backup. Restoring an old backup restores old values.
- Images and source history. A password that was committed and then removed stays in the history. A password that was copied into an image layer stays in the layer.
- Diagnostic archives. A support bundle that collects manifests and logs may hold environment values.

Deleting the Secret object removes none of these copies. The copy that matters is the one an attacker can read, so list the copies and their readers.

## Check A Pod For Distribution

Find which pods receive a Secret and how. This command lists each container that takes a value from a Secret by an environment variable:

```sh
kubectl get pods -A -o json | jq -r '.items[] | .metadata.namespace as $ns | .metadata.name as $p | .spec.containers[] | select(any(.env[]?; .valueFrom.secretKeyRef != null)) | $ns + "/" + $p + " " + .name'
```

In this playground the command prints nothing for the Starfleet workloads, because none of them takes a value from a Secret. A line in the output of a real cluster means that anyone with exec into that container can read the value from the environment. List the mounted volumes in the same way when a file is used.

## Link Each Route To A Control

Use this list when you review a design.

- Remove broad `get`, `list` and `watch` on Secrets, and name the objects with `resourceNames`.
- Do not grant `create` on `pods` or `pods/exec` to identities that do not need them.
- Keep values out of logs and audit bodies.
- Limit access to backups to the same people who may read the Secrets.
- Rotate a value when any copy may have been exposed.

## Why Retention Needs An Owner

Every copy of a value needs an owner who decides how long it lives and who may read it. Without an owner, a log file or a backup stays for years and keeps a credential that was rotated long ago. Set a retention period for each store, and delete or expire the data when the period ends. A short period limits how many old values an attacker finds in one place.

Also record which copies a rotation must reach. A rotation replaces the value at the issuer, in the Secret and in every consumer. A copy in a backup is not replaced, but the old value no longer works at the issuer, so the copy has no use for an attacker. This is why rotation is the control that makes retained copies harmless.
