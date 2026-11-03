# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Add the LimitRange

Add the defaults first, so pods that declare nothing still pass the quota. Save this as `limitrange.yaml`:

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
```

Apply it:

```sh
kubectl apply -f limitrange.yaml
```

## Step 2: Add the ResourceQuota

Save this as `quota.yaml`:

```yaml
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

Apply it and read the usage:

```sh
kubectl apply -f quota.yaml
kubectl describe resourcequota outpost-quota -n outpost
```

The table should list the three hard limits and the current use of `drifter`.

## Step 3: Test a pod without resources

Ask the API server for a pod that declares nothing and read the result:

```sh
kubectl run quota-probe -n outpost --image=curlimages/curl:8.22.0 --dry-run=server -o jsonpath='{.spec.containers[0].resources}{"\n"}'
```

The result should list the default request and the default limit. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-01/labs/lab-01 --keep
```

All four checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-030/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-030-01
```
