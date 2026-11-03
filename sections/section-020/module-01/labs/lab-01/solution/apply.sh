#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl delete cronjob cache-warmer -n starfleet
kubectl delete daemonset node-helper -n starfleet
kubectl delete clusterrolebinding backup-helper-admin
echo "[solution] Applied."
