---
estimated_duration: 35m
---

# Lab: Denial Of Service Capstone

Integrated capstone for the section. One namespace needs a bounded quota with defaults, one noisy service account needs its own API pool, and one workload needs a budget. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-044-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-outpost-quota.sh` | outpost has a ResourceQuota with a pod limit of 6 or fewer and a memory cap |
| `validate-outpost-limitrange.sh` | outpost has a LimitRange with default memory request and limit |
| `validate-outpost-defaults-applied.sh` | A pod without resources is accepted and receives a memory limit |
| `validate-apf-exporter.sh` | report-exporter has its own Limited priority level that rejects when full |
| `validate-probe-budget.sh` | A PodDisruptionBudget for probe allows one disruption |
| `validate-workloads-available.sh` | The four example Deployments are available |
