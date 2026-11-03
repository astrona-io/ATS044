# Restricting Network Paths With NetworkPolicy - Playground

- **Slug:** ats-044-playground-050-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED - never run against a live cluster

A kind cluster (Kubernetes 1.35, one worker) with the Calico network plugin and the Starfleet workloads, for writing NetworkPolicy.

## Run it

```sh
astrona run -c .
astrona destroy ats-044-playground-050-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
