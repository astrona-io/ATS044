---
estimated_duration: 35m
---

# Lab: Network Attacker Capstone

Integrated capstone for the section. A broken Service must be repaired and the namespace must then accept only the traffic of `shuttle`. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-044-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-radar-service-fixed.sh` | The Service radar has ready endpoints, port 80 and shuttle reaches it before the policy |
| `validate-default-deny-exists.sh` | starfleet has a default-deny ingress policy |
| `validate-shuttle-reaches-radar-and-scout.sh` | shuttle can reach radar and scout |
| `validate-drifter-blocked.sh` | drifter cannot reach radar or scout |
| `validate-workloads-available.sh` | The example Deployments are available |
