---
estimated_duration: 20m
---

# Lab: Deliver A Secret As A File

Graded lab for the second module. The Deployment `probe` receives a database password in an environment variable. The task changes the delivery to a read-only file. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-02/labs/lab-01
astrona destroy ats-044-lab-060-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-env-secret-removed.sh` | probe takes no value from a Secret through an environment variable |
| `validate-probe-secret-mounted-readonly.sh` | probe mounts report-db read-only and is rolled out |
| `validate-workloads-available.sh` | The example Deployments are available |
