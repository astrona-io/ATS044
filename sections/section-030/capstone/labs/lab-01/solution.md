# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Bound the namespace outpost

Add the defaults and the quota in one file named `outpost.yaml`:

```yaml
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
```

Apply it and test a pod that declares nothing:

```sh
kubectl apply -f outpost.yaml
kubectl run quota-probe -n outpost --image=curlimages/curl:8.22.0 --dry-run=server -o jsonpath='{.spec.containers[0].resources}{"\n"}'
```

The result should list the default values. Grade this step:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/capstone/labs/lab-01 --keep
```

## Step 2: Give report-exporter its own pool

Save this as `exporter.yaml`:

```yaml
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
```

Apply it and check that the schema lists the new level:

```sh
kubectl apply -f exporter.yaml
kubectl get flowschema exporter-flow
```

## Step 3: Protect probe

```sh
kubectl apply -f - <<'Y'
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
```

Read the allowed disruptions. It should be 1:

```sh
kubectl get pdb probe-pdb -n starfleet -o jsonpath='{.status.disruptionsAllowed}{"\n"}'
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/capstone/labs/lab-01 --keep
```

All six checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-030
```
