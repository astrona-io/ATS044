# API Protection And Availability - Playground

- **Slug:** ats-044-playground-030-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED - never run against a live cluster

A single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads and a service account `batch-importer` in `starfleet` for API Priority and Fairness rules.

## Run it

```sh
astrona run -c .
astrona destroy ats-044-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
