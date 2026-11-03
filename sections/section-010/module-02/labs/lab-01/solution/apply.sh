#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'EOT'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: shuttle-reader
  namespace: starfleet
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["shuttle-settings"]
    verbs: ["get"]
EOT
echo "[solution] Applied."
