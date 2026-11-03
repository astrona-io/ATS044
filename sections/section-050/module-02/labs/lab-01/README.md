---
estimated_duration: 25m
---

# Lab: Default Deny With An Explicit Allow

Graded lab for the second module. All pods in `starfleet` accept traffic from anywhere. The task allows exactly one path. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-044-lab-050-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-default-deny-exists.sh` | starfleet has a default-deny ingress policy |
| `validate-shuttle-reaches-scout.sh` | shuttle can reach scout |
| `validate-drifter-blocked.sh` | drifter cannot reach scout |
| `validate-probe-blocked.sh` | shuttle cannot reach probe |
| `validate-workloads-available.sh` | The example Deployments are available |
