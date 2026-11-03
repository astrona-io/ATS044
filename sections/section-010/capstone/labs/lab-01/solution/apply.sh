#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl delete clusterrolebinding drifter-view
kubectl patch deployment shuttle -n starfleet --type merge -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl delete rolebinding probe-secrets -n starfleet
kubectl delete role probe-secrets -n starfleet
kubectl rollout status deployment/shuttle -n starfleet --timeout=180s
echo "[solution] Applied."
