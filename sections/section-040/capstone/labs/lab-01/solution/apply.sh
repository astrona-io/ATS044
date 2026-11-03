#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl patch deployment shuttle -n starfleet --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/securityContext","value":{"runAsNonRoot":true,"runAsUser":10001,"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]'
kubectl rollout status deployment/shuttle -n starfleet --timeout=120s
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
