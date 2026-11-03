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
---
apiVersion: flowcontrol.apiserver.k8s.io/v1
kind: PriorityLevelConfiguration
metadata:
  name: exporter-limited
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
  name: exporter-flow
spec:
  matchingPrecedence: 5000
  priorityLevelConfiguration:
    name: exporter-limited
  distinguisherMethod:
    type: ByUser
  rules:
    - subjects:
        - kind: ServiceAccount
          serviceAccount:
            name: report-exporter
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
