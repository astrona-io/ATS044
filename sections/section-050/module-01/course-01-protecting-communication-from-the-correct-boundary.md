---
draft: true
exam_objectives:
  - Attacker on the Network
---
# Protecting Communication From The Correct Boundary

Two applications need encrypted communication and consistent request telemetry. A service mesh adds infrastructure for communication between services, commonly through proxies or node-level components controlled by a mesh control plane. Depending on the implementation, it can provide identity, encryption, request routing, retries and observability.

A mesh and a network policy solve related but distinct problems. A policy can limit which network connections are allowed. A mesh can apply application-level behavior and authenticated service identities. Their combination can provide several layers of control, but installing either does not automatically configure every protection an application needs.

Transport Layer Security (TLS) protects a connection against network observation and tampering when correctly configured. The client verifies the server's certificate identity and trust chain. Encryption without correct identity verification can still connect securely to the wrong party. Mutual TLS adds certificate authentication of the client as well as the server.

Authentication identifies a peer; authorization decides what that peer may do. Mutual TLS can establish that a request came from `shuttle`, but a separate policy may still be needed to decide whether `shuttle` may call a particular operation. Encrypted traffic is not proof of permitted application behavior.

Retries also need care. Repeating a read may be safe; repeating a payment request without an idempotency mechanism can duplicate an effect. Timeouts and retry budgets prevent failed dependencies from consuming all available resources. A mesh cannot infer the safety of every application operation.

Choose the control from the requirement: connection isolation, verified transport identity, encrypted bytes or application permission. Explaining each separately avoids treating “secure networking” as one setting that guarantees all four.

## Separating Peer Identity From User Permission

Mutual TLS can establish that a connection comes from the `shuttle` service identity and reaches the intended `probe` service identity. Certificate trust, identity mapping and rotation support that result. It does not automatically establish which human user initiated the work or whether that user may perform the requested operation.

An application can require both service identity and an end-user credential. The service mesh may enforce some policy, while application code enforces data-specific permissions. State which layer evaluates which identity. A valid service certificate is not a substitute for checking access to a particular customer's record.

Transport encryption protects data on the configured connection path. If TLS terminates at a proxy and the next hop is plaintext, the encrypted boundary ends there unless another protected connection is established. Claims of end-to-end protection should identify each hop and where plaintext exists rather than infer safety from one external secure endpoint.

## Retry And Timeout Tradeoffs

Suppose `shuttle` retries a report creation request after a timeout. The server may have completed the write before the response was lost. Retrying can create another report unless the operation uses a stable request identity or other deduplication. Transport failure and transaction failure are not equivalent observations.

Timeouts bound how long callers wait, while retry counts and backoff bound repeated attempts. Retries can improve response to a transient failure but increase load on an overloaded dependency. A circuit breaker can limit repeated attempts when failure persists. These controls need to fit the application's semantics and capacity.

A mesh supplies configurable mechanisms, not universal policy correctness. The useful design explains the authenticated peer, permitted operation, encrypted hops and safe failure behavior. NetworkPolicy can then narrow connection paths while higher layers enforce the remaining requirements.

## Checking TLS Verification By Hand

Every pod has a TLS server it can test against: the Kubernetes API server. Its certificate is signed by the cluster certificate authority (CA), and the CA certificate is mounted in each pod. A TLS client checks three things: the certificate chain leads to a trusted CA, the certificate has not expired, and the host name that the client asked for appears in the certificate.

<!-- astrona:playground:renew -->
First send a request with no trusted CA. The `curl` command in `shuttle` does not know the cluster CA:

```sh
kubectl exec -n starfleet deploy/shuttle -- sh -c 'curl -sS -m 5 https://kubernetes.default.svc/version; echo "exit=$?"'
```

The command fails with a message about the certificate issuer and the exit code `60`. The client refuses to continue because it cannot verify the server. Now give it the CA file that is mounted in the pod:

```sh
kubectl exec -n starfleet deploy/shuttle -- sh -c 'curl -sS -m 5 --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt https://kubernetes.default.svc/version; echo "exit=$?"'
```

The server answers with its version and the exit code is `0`. The chain is trusted and the name `kubernetes.default.svc` is in the certificate. Third, keep the trusted CA but ask for a different host name that points to the same address:

```sh
API_IP=$(kubectl get service kubernetes -n default -o jsonpath='{.spec.clusterIP}')
kubectl exec -n starfleet deploy/shuttle -- sh -c "curl -sS -m 5 --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --resolve wrong.example.com:443:$API_IP https://wrong.example.com/version; echo exit=\$?"
```

The command fails with exit code `60` and a message about the host name, because `wrong.example.com` is not in the certificate. The chain is trusted, yet the name check fails. This shows that an attacker with a valid certificate for another name cannot pose as the server.

The flag `-k` (insecure) turns the checks off, and the request then succeeds even against an impostor. Code that disables verification gives the attacker on the network the same position as a network with no TLS at all.

## What Each Control Answers

An attacker on the network has three abilities: reading traffic, changing traffic and sending traffic as someone else. Each ability has a control that answers it.

- Encryption answers reading. The attacker sees bytes that look random.
- Integrity checks, which TLS includes, answer changing. A changed message fails verification and the connection closes.
- Authentication answers sending as someone else. The server proves its identity with a certificate, and in mutual TLS the client proves its identity as well.
- Authorization answers what an authenticated peer may do. It is a separate decision, made by a policy or by application code.

If one of the four is missing, the others do not compensate. Encrypted traffic to an unverified server goes to the attacker in encrypted form.

## Where The Encrypted Path Ends

A client may open a TLS connection to a gateway or proxy, and the proxy may open a second connection to the pod. Each connection is protected separately. If the second connection is plain HTTP, an attacker on the network between the proxy and the pod can read and change the traffic. When you review a design, draw each hop and mark whether it is encrypted and whether each end verifies the other. The weakest hop sets the level of protection for the whole path.

Certificates also expire. A certificate that is not renewed in time makes clients refuse the connection, and teams then tend to disable verification to restore service. Automatic renewal and an alert before expiry remove that pressure.

## A Review Checklist

Use these questions for each connection in a design:

1. Who can observe the bytes on this hop, and are they encrypted?
2. Does the client verify the server certificate chain and name?
3. Does the server verify the client, and with which identity?
4. Which policy decides what that identity may call?
5. What happens to the request when a certificate expires or a dependency is slow?

A design that answers all five for every hop has a clear threat model for the network attacker.

## Common pitfalls

> [!WARNING]
> Encryption, authentication and authorization are separate properties. A service mesh does not automatically make application retries safe or replace NetworkPolicy.
