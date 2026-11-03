---
estimated_duration: 30m
---

# Lab: Persistence Capstone

Integrated capstone for the section. A CronJob with a cluster-admin identity, a legacy token and a host path workload give an attacker three ways to stay. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-044-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rogue-objects-removed.sh` | The CronJob cache-warmer and its cluster-admin binding are gone |
| `validate-legacy-token-removed.sh` | No legacy token Secret exists in starfleet |
| `validate-node-agent-removed.sh` | No pod in outpost mounts a host path |
| `validate-outpost-enforces-baseline.sh` | outpost enforces the baseline Pod Security level |
| `validate-workloads-available.sh` | The four example Deployments are available |
