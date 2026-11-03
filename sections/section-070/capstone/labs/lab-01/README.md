---
estimated_duration: 30m
---

# Lab: Privilege Escalation Capstone

Integrated capstone for the section. A release job holds surplus authority and the namespace accepts dangerous pods. The task closes both routes. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/capstone/labs/lab-01
astrona destroy ats-044-capstone-070
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-cannot-move-authority.sh` | shuttle cannot create roles, role bindings or exec |
| `validate-shuttle-keeps-its-task.sh` | shuttle can still patch Deployments |
| `validate-privileged-pods-rejected.sh` | a privileged pod and a hostPath pod are rejected in starfleet |
| `validate-plain-pod-accepted.sh` | a plain pod is accepted in starfleet |
| `validate-workloads-available.sh` | The example Deployments are available |
