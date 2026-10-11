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

## Common pitfalls

> [!WARNING]
> Encoding is not encryption, and encryption does not prevent an authorized reader from receiving plaintext. Diagnostic access, backups and historical artifacts can expose data outside its primary store.
