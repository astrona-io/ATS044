# Sensitive Data Access Paths - Playground

- **Slug:** ats-044-playground-060-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED - never run against a live cluster

A single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads, two Secrets and a Role that lets shuttle read Secrets.

## Run it

```sh
astrona run -c .
astrona destroy ats-044-playground-060-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
