---
estimated_duration: 30m
---

# Lab: Sensitive Data Capstone

Integrated capstone for the section. One reader has too much access to Secrets and one workload receives a password in the environment. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-044-capstone-060
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-secret-access-narrowed.sh` | shuttle cannot list Secrets or read report-db |
| `validate-shuttle-keeps-its-token.sh` | shuttle can still read shuttle-token |
| `validate-probe-env-secret-removed.sh` | probe takes no value from a Secret through an environment variable |
| `validate-probe-secret-mounted-readonly.sh` | probe mounts report-db read-only and is rolled out |
| `validate-workloads-available.sh` | The example Deployments are available |
