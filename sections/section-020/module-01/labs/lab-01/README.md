---
estimated_duration: 20m
---

# Lab: Persistence Through Cluster Objects

Graded lab for the first module. Three objects that no pipeline created keep running or keep authority: a CronJob, a DaemonSet and a cluster-admin binding. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-044-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-rogue-cronjob-removed.sh` | The CronJob cache-warmer is gone together with its Jobs |
| `validate-rogue-daemonset-removed.sh` | The DaemonSet node-helper is gone |
| `validate-backup-helper-admin-removed.sh` | backup-helper is not bound to cluster-admin |
| `validate-workloads-available.sh` | The four example Deployments are still available |
