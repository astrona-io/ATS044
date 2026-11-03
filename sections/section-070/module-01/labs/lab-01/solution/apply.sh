#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'Y'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: release-manager
  namespace: starfleet
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch"]
Y
echo "[solution] Applied."
