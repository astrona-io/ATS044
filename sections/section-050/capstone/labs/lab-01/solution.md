# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/capstone/labs/lab-01
```

## Step 1: Repair the Service

Find the failing stage with the endpoints and the labels:

```sh
kubectl get endpoints radar -n starfleet
kubectl get service radar -n starfleet -o jsonpath='{.spec.selector}{"\n"}'
kubectl get pods -n starfleet --show-labels
```

The selector names `app=radar-v2` and the pods carry `app=radar`. Patch the selector and the target port, then test:

```sh
kubectl patch service radar -n starfleet --type=merge -p '{"spec":{"selector":{"app":"radar"}}}'
kubectl patch service radar -n starfleet --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":9898}]'
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://radar/healthz
```

The request should return a short JSON status. Grade this step:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/capstone/labs/lab-01 --keep
```

## Step 2: Restrict the namespace

Save this as `policies.yaml`:

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
```

Apply it and test both clients. The `shuttle` requests should return a body and the `drifter` request should time out:

```sh
kubectl apply -f policies.yaml
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://radar/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://scout/healthz
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://radar.starfleet/healthz
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/capstone/labs/lab-01 --keep
```

All five checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-050
```
