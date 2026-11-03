---
estimated_duration: 30m
---

# Lab: Trust Boundaries And Data Flow Capstone

Integrated capstone for the section. Three unneeded authorities sit on the workloads: a cluster-wide read grant, a mounted token and a Secret grant. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-044-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-drifter-cannot-read-cluster.sh` | drifter has no cluster-wide read access |
| `validate-shuttle-token-removed.sh` | No running shuttle pod mounts a service account token |
| `validate-probe-cannot-read-secrets.sh` | probe cannot read or list Secrets in starfleet |
| `validate-workloads-available.sh` | All four Deployments are available |
