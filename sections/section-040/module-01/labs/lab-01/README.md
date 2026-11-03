---
estimated_duration: 20m
---

# Lab: Harden A Container With securityContext

Graded lab for the first module. `drifter` in `outpost` runs with the defaults of the image. The task removes the options that a compromised process would use. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-044-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-drifter-context.sh` | The container of drifter has a non-root numeric user, no privilege escalation, dropped capabilities and a read-only root file system |
| `validate-drifter-behaviour.sh` | The running drifter process is not root and cannot write to its root file system |
| `validate-workloads-available.sh` | The four example Deployments are available |
