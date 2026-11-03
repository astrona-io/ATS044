---
estimated_duration: 20m
---

# Lab: Persistence Through Credentials And Nodes

Graded lab for the second module. A legacy token Secret and a Deployment with a host path mount sit in `starfleet`. The task removes both and enforces the baseline level. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-044-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-legacy-token-removed.sh` | No legacy service account token Secret exists in starfleet |
| `validate-hostpath-workload-removed.sh` | No pod in starfleet mounts a host path |
| `validate-namespace-enforces-baseline.sh` | starfleet enforces the baseline Pod Security level |
| `validate-workloads-available.sh` | The example Deployments are still available |
