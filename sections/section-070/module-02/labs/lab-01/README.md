---
estimated_duration: 15m
---

# Lab: Enforce Pod Security Admission

Graded lab for the second module. The namespace `starfleet` accepts privileged pods and host paths. The task enforces the baseline level. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-02/labs/lab-01
astrona destroy ats-044-lab-070-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-privileged-pods-rejected.sh` | a privileged pod and a hostPath pod are rejected in starfleet |
| `validate-plain-pod-accepted.sh` | a plain pod is accepted in starfleet |
| `validate-workloads-available.sh` | The example Deployments are available |
