---
estimated_duration: 20m
---

# Lab: Isolate A Suspected Workload

Graded lab for the second module. `drifter` is suspected to be compromised. The task cuts its network path without harming the healthy workloads. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-044-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-drifter-isolated.sh` | drifter cannot reach scout and a NetworkPolicy with Egress selects it |
| `validate-shuttle-still-works.sh` | shuttle can still reach scout |
| `validate-workloads-available.sh` | The four example Deployments are available |
