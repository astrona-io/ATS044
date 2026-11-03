# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Harden shuttle

Patch the container and wait for the rollout:

```sh
kubectl patch deployment shuttle -n starfleet --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/securityContext","value":{"runAsNonRoot":true,"runAsUser":10001,"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]'
kubectl rollout status deployment/shuttle -n starfleet
```

Check the user ID and a write. The user should be `10001` and the write should fail:

```sh
kubectl exec -n starfleet deploy/shuttle -- id -u
kubectl exec -n starfleet deploy/shuttle -- sh -c 'touch /tmp/x && echo writable'
```

Grade this step:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/capstone/labs/lab-01 --keep
```

## Step 2: Isolate drifter

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

Apply it and test both workloads. The first request should time out and the second should return a body:

```sh
kubectl apply -f isolate.yaml
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://scout.starfleet/healthz
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://scout/healthz
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/capstone/labs/lab-01 --keep
```

All five checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-040
```
