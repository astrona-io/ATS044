#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline --overwrite
sleep 3
echo "[solution] Applied."
