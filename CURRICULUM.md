# Curriculum Coverage

Exam: Kubernetes and Cloud Native Associate (KCSA). Domain: Kubernetes Threat Model (16%).

Verified against the [official objectives](https://training.linuxfoundation.org/certification/kubernetes-and-cloud-native-security-associate-kcsa/) on 2026-10-11. Module titles and questions are original teaching material, not official exam questions.

| Section | Official objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | Kubernetes Trust Boundaries and Data Flow | 1 | Written; review pending |
| 020 | Persistence | 1 | Written; review pending |
| 030 | Denial of Service | 1 | Written; review pending |
| 040 | Malicious Code Execution and Compromised Applications in Containers | 1 | Written; review pending |
| 050 | Attacker on the Network | 1 | Written; review pending |
| 060 | Access to Sensitive Data | 1 | Written; review pending |
| 070 | Privilege Escalation | 1 | Written; review pending |

| Section / module | Module | Teaching lessons | Measurable outcomes |
| --- | --- | --- | --- |
| 010 / 01 | Trust Boundaries And Security Data Flow | 1 | Identify assets, actors and entry points in a Kubernetes design.; Trace a request across network, identity and execution boundaries.; Distinguish trusted control components from untrusted workload inputs.; Relate each boundary to preventive and detective controls. |
| 020 / 01 | Persistence After Workload Compromise | 1 | Distinguish attacker persistence from ordinary application storage persistence.; Identify durable configuration, identity and data changes that survive Pod deletion.; Relate reconciliation to trusted and compromised desired state.; Describe recovery that restores inputs and revokes authority. |
| 030 / 01 | Denial Of Service And Shared Capacity | 1 | Identify API, node and application availability assets.; Compare requests, limits, quotas and rate controls.; Explain overload amplification through retries and dependencies.; Relate recovery capacity and evidence to service availability. |
| 040 / 01 | Compromised Application Consequences | 1 | Distinguish application compromise from container escape.; Trace available credentials, mounts and network paths after compromise.; Relate code defenses and containment to different outcomes.; Describe evidence and trusted recovery for an affected workload. |
| 050 / 01 | Network Attackers And Peer Trust | 2 | Identify disclosure, tampering and impersonation threats along a request path.; Distinguish reachability restriction from transport identity protection.; Explain certificate verification and encrypted-hop boundaries.; Relate network evidence to application authorization. |
| 060 / 01 | Sensitive Data Access Paths | 1 | Identify sensitive data in live resources, mounted files and retained copies.; Distinguish encoding, encryption and authorized plaintext access.; Trace diagnostic and indirect permission exposure.; Describe revocation and recovery after credential disclosure. |
| 070 / 01 | Privilege Escalation And Indirect Authority | 1 | Distinguish direct grants from routes to broader authority.; Identify risky workload creation, identity and host interfaces.; Relate RBAC, admission and runtime restrictions to escalation prevention.; Explain why effective permission review includes alternate paths. |

Every section begins with an introduction. Every module ends with a summary before the next module. YAML checkpoint banks follow selected section summaries; a domain review bank closes the course. They are indexed separately for future application integration.

This course has no labs or playgrounds, as requested by the maintainer. All material is readable without a cluster. Technical content remains draft until review; no runtime execution or lab validation is claimed.
