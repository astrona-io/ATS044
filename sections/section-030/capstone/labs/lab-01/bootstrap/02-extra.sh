#!/usr/bin/env bash
# Part of the starting state: probe runs two replicas so that a budget can allow a disruption.
set -euo pipefail
kubectl -n starfleet scale deployment/probe --replicas=2
kubectl -n starfleet rollout status deployment/probe --timeout=180s
