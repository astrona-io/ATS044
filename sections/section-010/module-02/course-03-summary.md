---
draft: true
exam_objectives:
  - Kubernetes Trust Boundaries and Data Flow
---
# Summary

An API request passes three ordered stages. Authentication produces an identity, authorization checks the identity against rules and admission checks the content of the object for requests that change state. A 401 means the credential is unknown. A 403 means the identity is known and lacks a permission. Public paths such as `/version` are readable without a credential.

Server-side dry run sends a request through every stage except the write to etcd. It is the safe way to test what a request would do.

Pod-to-pod traffic does not pass the API server. By default every pod can reach every pod in every namespace, and the receiver sees only a source IP address. A namespace scopes names and permissions in the API but does not stop network connections. Network policies limit connections, mutual TLS proves the peer, and application authorization decides what the caller may do.

Key facts:

- The order is authentication, authorization, then admission, then storage in etcd.
- Admission does not run for reads.
- Service DNS names resolve from every namespace.
- A source IP address is weak evidence of identity.

<!-- astrona:playground:destroy -->
