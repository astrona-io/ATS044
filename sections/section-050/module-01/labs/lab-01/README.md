---
estimated_duration: 20m
---

# Lab: Repair A Service Path

Graded lab for the first module. The Service `radar` in `starfleet` has two faults. The task finds each stage that fails and corrects it. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-01/labs/lab-01
astrona destroy ats-044-lab-050-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-radar-service-fixed.sh` | The Service radar has ready endpoints, port 80 and shuttle reaches it |
| `validate-workloads-available.sh` | The example Deployments are available |
