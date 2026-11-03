#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl apply -f - <<'Y'
apiVersion: flowcontrol.apiserver.k8s.io/v1
kind: PriorityLevelConfiguration
metadata:
  name: importer-limited
spec:
  type: Limited
  limited:
    nominalConcurrencyShares: 5
    limitResponse:
      type: Reject
---
apiVersion: flowcontrol.apiserver.k8s.io/v1
kind: FlowSchema
metadata:
  name: importer-flow
spec:
  matchingPrecedence: 5000
  priorityLevelConfiguration:
    name: importer-limited
  distinguisherMethod:
    type: ByUser
  rules:
    - subjects:
        - kind: ServiceAccount
          serviceAccount:
            name: batch-importer
            namespace: starfleet
      resourceRules:
        - verbs: ["*"]
          apiGroups: ["*"]
          resources: ["*"]
          clusterScope: true
          namespaces: ["*"]
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: probe-pdb
  namespace: starfleet
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: probe
Y
sleep 5
echo "[solution] Applied."
