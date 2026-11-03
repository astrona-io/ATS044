# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-02/labs/lab-01
```

## Step 1: Check the starting state

The pod can reach `scout`:

```sh
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://scout.starfleet/healthz
```

## Step 2: Add the isolating policy

Save this as `isolate.yaml`:

```yaml
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
```

Apply it:

```sh
kubectl apply -f isolate.yaml
```

## Step 3: Prove the result

Repeat the request. It should time out after five seconds without a body. Then check that `shuttle` still works:

```sh
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://scout.starfleet/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://scout/healthz
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-02/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-040-02
```
