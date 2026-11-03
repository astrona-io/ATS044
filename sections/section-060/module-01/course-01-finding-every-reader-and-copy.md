---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Finding Every Reader And Copy

The `probe` workload uses a database password and produces confidential reports. Sensitive data can appear in more places than the primary database: application programming interface (API) resources, mounted files, process environments, logs, snapshots and diagnostic archives. A useful threat model traces each copy and who can read it.

## Live Credential Paths

A Secret object can hold sensitive values, but base64 representation is encoding rather than encryption. API permissions determine which identities can retrieve it through the normal resource path. A workload that receives the value can use plaintext according to its process behavior, even when the stored form is encrypted.

A person unable to read the Secret directly may have another route if granted broad process execution, workload creation or host access. A new Pod that mounts data, a diagnostic session or a node administrator can expose sensitive material depending on the effective controls. Evaluate the result of allowed operations rather than only their names.

Environment values can appear in diagnostic inspection, while files can be read through their mounts and permissions. An unnecessary helper container with the same mount becomes another reader. Reduce distribution to the processes that actually need the credential or report data.

## Logs, Backups And Historical Copies

Applications can accidentally record passwords or confidential input in errors. Audit policy can record request or response bodies containing sensitive values. Collection and retention systems then become data stores with their own access controls. A protection applied to the original Secret does not automatically apply to those copies.

Backups and snapshots can retain old credentials after current rotation. Source history and registry layers can preserve values removed from the latest visible file. Deleting one current object therefore does not prove all copies are gone or inaccessible.

Classify retained data, restrict readers and choose retention appropriate to the business and investigation needs. Encryption protects defined storage boundaries, but keys and authorized readers remain part of the model. A backup key stored beside a broadly accessible copy can undermine the intended protection.

## Data-Specific Authorization

An application may legitimately read several reports while each user is allowed only their own organization's records. The application must mediate that broader service authority. Network isolation cannot decide ownership of a report, and a valid service identity cannot automatically stand in for every user's permission.

A read-only credential reduces modification risk while still permitting disclosure. A narrowly scoped write credential limits a different set of operations. Choose authority according to the exact task and identify what a compromised process can still access legitimately.

## Responding To Disclosure

If a credential was exposed, remove the disclosure path and revoke or rotate it at its issuer. Update consumers through their actual delivery and reload mechanism. A new Secret value does not automatically invalidate the old credential or replace a running environment variable.

Assess actions possible during the exposed credential's validity and investigate relevant records. For confidential report exposure, revocation prevents future access but cannot undo a reader's past copy. Recovery and communication follow the actual data and organizational process rather than an assumption that deletion erases historical disclosure.

A complete data-access explanation identifies all readers, copies, identities and plaintext locations. That makes confidentiality controls testable and exposes indirect routes that a single permission check can miss.

## Look At A Secret

<!-- astrona:playground:renew -->
The playground holds two Secrets in `starfleet`. List them:

```sh
kubectl get secrets -n starfleet
```

The list shows `report-db` and `shuttle-token`. The list does not show the values. Read the stored form of one value:

```sh
kubectl get secret report-db -n starfleet -o jsonpath='{.data.password}{"\n"}'
```

The output is a string of letters and digits that is not readable. Kubernetes stores each value in the `data` field as base64. Decode it:

```sh
kubectl get secret report-db -n starfleet -o jsonpath='{.data.password}' | base64 -d; echo
```

The command prints the password in plain text. Base64 is a way to write bytes as text. It uses no key, so anyone who can read the object can reverse it in one command. This is why base64 is encoding and not encryption.

## Find The Direct Readers

Reading a Secret needs the `get` verb, or the `list` or `watch` verb, on the resource `secrets`. The `list` verb returns the full objects, values included, so it gives the same access as `get` for every Secret in the namespace. Ask the API server whether the service account of `shuttle` may read Secrets:

```sh
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secrets -n outpost --as=system:serviceaccount:starfleet:shuttle
```

The first two answers are `yes`, because a Role in `starfleet` grants the verbs. The third answer is `no`, because a Role applies only in its own namespace. A client that only needs to show a status page has no reason to read the database password, yet this Role lets a compromised `shuttle` read every Secret in the namespace.

To find all readers, list the Roles and bindings that mention Secrets:

```sh
kubectl get roles -n starfleet -o json | jq -r '.items[] | select(any(.rules[]; (.resources // []) | index("secrets") != null)) | .metadata.name'
kubectl get rolebindings -n starfleet -o json | jq -r '.items[] | .metadata.name + " -> " + ([.subjects[]? | .kind + "/" + .name] | join(","))'
```

The first command prints the name of each Role with a rule for Secrets. The second prints each binding and its subjects. A ClusterRole bound with a ClusterRoleBinding reaches every namespace, so check `clusterrolebindings` as well. The cluster administrator group also reads every Secret, and so does every identity that can act as that group.

## Narrow Rules With Resource Names

A rule can name the objects that it covers. A rule with `resourceNames: ["shuttle-token"]` and the verb `get` allows one Secret and no other. The `list` and `watch` verbs cannot be limited this way for a collection request, so a role that must be narrow lists only `get`. A client that holds `get` on one name cannot discover the names of the other Secrets.

## Check What You Found

Write down, for each Secret, the identities that can read it and the reason each needs it. An entry without a reason is a finding to remove. The Role in the playground has no reason for `shuttle` to read `report-db`, so it is the first finding.

## Common pitfalls

> [!WARNING]
> Encoding is not encryption, and encryption does not prevent an authorized reader from receiving plaintext. Diagnostic access, backups and historical artifacts can expose data outside its primary store.
