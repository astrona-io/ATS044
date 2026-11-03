#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl delete secret ci-runner-token -n starfleet
kubectl delete deployment node-agent -n starfleet
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline --overwrite
echo "[solution] Applied."
