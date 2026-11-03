#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl patch service radar -n starfleet --type=merge -p '{"spec":{"selector":{"app":"radar"}}}'
kubectl patch service radar -n starfleet --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":9898}]'
kubectl apply -f - <<'Y'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-shuttle
  namespace: starfleet
spec:
  podSelector:
    matchExpressions:
      - key: app
        operator: In
        values: ["radar", "scout"]
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 9898
Y
sleep 10
echo "[solution] Applied."
