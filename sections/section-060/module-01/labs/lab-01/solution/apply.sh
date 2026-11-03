#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'Y'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: shuttle-secrets
  namespace: starfleet
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["shuttle-token"]
    verbs: ["get"]
Y
echo "[solution] Applied."
