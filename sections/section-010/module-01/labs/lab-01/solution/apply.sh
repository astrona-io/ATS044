#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
patch='{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
for name in scout probe shuttle; do
  kubectl patch deployment "$name" -n starfleet --type merge -p "$patch"
done
kubectl patch deployment drifter -n outpost --type merge -p "$patch"
for name in scout probe shuttle; do
  kubectl rollout status "deployment/$name" -n starfleet --timeout=180s
done
kubectl rollout status deployment/drifter -n outpost --timeout=180s
echo "[solution] Applied."
