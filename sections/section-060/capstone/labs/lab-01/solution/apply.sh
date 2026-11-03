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
kubectl patch deployment probe -n starfleet --type=json -p '[{"op":"remove","path":"/spec/template/spec/containers/0/env"},{"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"report-db","mountPath":"/etc/report-db","readOnly":true}]},{"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"report-db","secret":{"secretName":"report-db","defaultMode":256}}]}]'
kubectl rollout status deployment/probe -n starfleet --timeout=120s
echo "[solution] Applied."
