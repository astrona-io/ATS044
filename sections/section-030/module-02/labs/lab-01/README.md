---
estimated_duration: 25m
---

# Lab: Limit A Noisy Client And Protect probe

Graded lab for the second module. A batch service account needs its own API pool, and `probe` needs a disruption budget. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-044-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-apf-priority-level.sh` | The level importer-limited is Limited with a small share and rejects when full |
| `validate-apf-flow-schema.sh` | The FlowSchema importer-flow sends batch-importer to that level |
| `validate-probe-budget.sh` | A PodDisruptionBudget for probe allows one disruption |
| `validate-workloads-available.sh` | The example Deployments are available |
