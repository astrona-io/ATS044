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
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline --overwrite
sleep 3
echo "[solution] Applied."
