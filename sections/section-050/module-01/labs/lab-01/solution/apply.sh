#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl patch service radar -n starfleet --type=merge -p '{"spec":{"selector":{"app":"radar"}}}'
kubectl patch service radar -n starfleet --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":9898}]'
sleep 3
echo "[solution] Applied."
