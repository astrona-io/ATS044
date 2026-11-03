---
estimated_duration: 15m
---

# Lab: Remove Surplus Release Rights

Graded lab for the first module. A release job can change roles, bindings and run commands in pods, which is more than its task needs. The task removes the surplus rights. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-01/labs/lab-01
astrona destroy ats-044-lab-070-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-cannot-move-authority.sh` | shuttle cannot create roles, role bindings or exec |
| `validate-shuttle-keeps-its-task.sh` | shuttle can still patch Deployments |
| `validate-workloads-available.sh` | The example Deployments are available |
