---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Summary

Encryption, authentication and authorization are separate properties. TLS verification checks three things: the certificate chain leads to a trusted certificate authority, the certificate is valid in time and the requested host name is in the certificate. A client that disables these checks gives a network attacker the position of an impostor server. Mutual TLS adds proof of the client identity, but a separate policy still decides what that identity may do.

A request path has stages: name resolution, Service address, ready endpoints, port mapping and application listener. The curl exit code identifies the stage: `6` for a name that does not resolve, `7` for a refused connection and `28` for a timeout. An empty endpoints list means that no ready pod matches the selector, and a wrong `targetPort` sends traffic to a port with no listener. A fix is proven from the client that had the problem.

A request leaves evidence in the client, proxies, the application, pod events and the API audit log. A missing log line does not prove that nothing happened. Timeouts bound waiting, and retries repeat requests. Retries without bounds or jitter increase the load on a struggling server, and they duplicate effects when the operation is not idempotent.

Key facts:

- Exit code `60` of curl means that the certificate check failed.
- A Service sends traffic only to ready pods that match its selector.
- A refused connection and a timeout have different causes.
- An idempotency key works only if the server uses it.

<!-- astrona:playground:destroy -->
