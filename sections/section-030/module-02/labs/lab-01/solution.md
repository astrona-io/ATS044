# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Create the priority level

Save this as `level.yaml`:

```yaml
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
```

Apply it:

```sh
kubectl apply -f level.yaml
```

## Step 2: Create the flow schema

Save this as `flow.yaml`:

```yaml
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
```

Apply it and read the list. The new schema should appear with the level `importer-limited`:

```sh
kubectl apply -f flow.yaml
kubectl get flowschema importer-flow
```

## Step 3: Create the budget

Save this as `pdb.yaml`:

```yaml
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
```

Apply it and read the allowed disruptions. With two ready replicas the value should be 1:

```sh
kubectl apply -f pdb.yaml
kubectl get pdb probe-pdb -n starfleet -o jsonpath='{.status.disruptionsAllowed}{"\n"}'
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-02/labs/lab-01 --keep
```

All four checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-030-02
```
