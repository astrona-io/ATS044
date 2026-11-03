---
estimated_duration: 15m
---

# Lab: Assets, Actors And Entry Points

Graded lab for the first module. Four workloads run with an API credential they never use. The task removes the credential from each of them. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-044-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-starfleet-tokens-removed.sh` | No running pod in starfleet mounts a service account token |
| `validate-outpost-token-removed.sh` | The drifter pod in outpost mounts no token |
| `validate-workloads-available.sh` | All four Deployments are available with the new pods |
