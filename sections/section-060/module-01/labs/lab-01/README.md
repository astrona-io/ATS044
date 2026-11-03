---
estimated_duration: 15m
---

# Lab: Narrow A Secret Reader

Graded lab for the first module. The service account of `shuttle` can read every Secret in `starfleet`, which includes the database password. The task narrows the Role. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-01/labs/lab-01
astrona destroy ats-044-lab-060-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-secret-access-narrowed.sh` | shuttle cannot list Secrets or read report-db |
| `validate-shuttle-keeps-its-token.sh` | shuttle can still read shuttle-token |
| `validate-workloads-available.sh` | The example Deployments are available |
