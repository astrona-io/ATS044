#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl delete cronjob cache-warmer -n starfleet
kubectl delete clusterrolebinding backup-helper-admin
kubectl delete secret shuttle-legacy-token -n starfleet
kubectl delete deployment node-agent -n outpost
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline --overwrite
echo "[solution] Applied."
