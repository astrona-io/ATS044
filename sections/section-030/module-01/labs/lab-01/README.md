---
estimated_duration: 20m
---

# Lab: Quota And Defaults For A Namespace

Graded lab for the first module. The namespace `outpost` has no resource boundary. The task adds a quota and a limit range that work together. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-044-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-outpost-quota.sh` | outpost has a ResourceQuota with a pod limit of 6 or fewer and a memory cap |
| `validate-outpost-limitrange.sh` | outpost has a LimitRange with default memory request and limit |
| `validate-outpost-defaults-applied.sh` | A pod without resources is accepted and receives a memory limit |
| `validate-workloads-available.sh` | The four example Deployments are still available |
