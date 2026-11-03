# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-02/labs/lab-01
```

## Step 1: Add the default deny

Save this as `deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Apply it:

```sh
kubectl apply -f deny.yaml
```

## Step 2: Allow shuttle to reach scout

Save this as `allow.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-shuttle-to-scout
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: scout
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
```

Apply it:

```sh
kubectl apply -f allow.yaml
```

## Step 3: Prove the three paths

The first request should return a body. The other two should time out:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://scout/healthz
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://scout.starfleet/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://probe:8080/get
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-02/labs/lab-01 --keep
```

All five checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-050-02
```
