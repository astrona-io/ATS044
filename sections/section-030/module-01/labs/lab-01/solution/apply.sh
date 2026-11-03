#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'Y'
apiVersion: v1
kind: LimitRange
metadata:
  name: outpost-defaults
  namespace: outpost
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 20m
        memory: 32Mi
      default:
        memory: 128Mi
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: outpost-quota
  namespace: outpost
spec:
  hard:
    pods: "6"
    requests.memory: 256Mi
    limits.memory: 512Mi
Y
echo "[solution] Applied."
