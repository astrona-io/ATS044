---
estimated_duration: 30m
---

# Lab: Compromised Application Capstone

Integrated capstone for the section. One workload must be hardened before it is exposed to an untrusted input, and one workload is suspected and must be isolated. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-044-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-context.sh` | The container of shuttle has a non-root numeric user, no privilege escalation, dropped capabilities and a read-only root file system |
| `validate-shuttle-behaviour.sh` | The running shuttle process is not root and cannot write to its root file system |
| `validate-drifter-isolated.sh` | drifter cannot reach scout and a NetworkPolicy with Egress selects it |
| `validate-shuttle-reaches-scout.sh` | shuttle can still reach scout |
| `validate-workloads-available.sh` | The four example Deployments are available |
