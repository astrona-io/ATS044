#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl patch deployment drifter -n outpost --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/securityContext","value":{"runAsNonRoot":true,"runAsUser":10001,"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]'
kubectl rollout status deployment/drifter -n outpost --timeout=120s
echo "[solution] Applied."
