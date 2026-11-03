#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'Y'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: drifter-isolate
  namespace: outpost
spec:
  podSelector:
    matchLabels:
      app: drifter
  policyTypes:
    - Egress
    - Ingress
Y
sleep 10
echo "[solution] Applied."
