---
estimated_duration: 20m
---

# Lab: Trust Boundaries And Request Data Flow

Graded lab for the second module. The `shuttle` service account may read every ConfigMap and Secret in `starfleet`. The task narrows the grant to one ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-044-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-reads-own-settings.sh` | shuttle can read the ConfigMap shuttle-settings |
| `validate-shuttle-cannot-read-other-data.sh` | shuttle cannot read other ConfigMaps, list ConfigMaps or read Secrets |
| `validate-shuttle-binding-kept.sh` | The shuttle service account is still bound by a RoleBinding in starfleet and runs |
