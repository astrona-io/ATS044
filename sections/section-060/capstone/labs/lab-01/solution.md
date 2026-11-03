# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/capstone/labs/lab-01
```

## Step 1: Narrow the reader

Find the grant and replace the Role. Save this as `role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: shuttle-secrets
  namespace: starfleet
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["shuttle-token"]
    verbs: ["get"]
```

Apply it and test the three answers. The first two should be `no` and the third should be `yes`:

```sh
kubectl apply -f role.yaml
kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secret/report-db -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secret/shuttle-token -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

Grade this step:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/capstone/labs/lab-01 --keep
```

## Step 2: Move the password to a file

Print the environment of `probe` to see the variable, then patch the Deployment:

```sh
kubectl exec -n starfleet deploy/probe -- env
kubectl patch deployment probe -n starfleet --type=json -p '[{"op":"remove","path":"/spec/template/spec/containers/0/env"},{"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"report-db","mountPath":"/etc/report-db","readOnly":true}]},{"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"report-db","secret":{"secretName":"report-db","defaultMode":256}}]}]'
kubectl rollout status deployment/probe -n starfleet --timeout=120s
```

The environment should no longer hold `DB_PASSWORD`, and `/etc/report-db/password` should exist. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/capstone/labs/lab-01 --keep
```

All five checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-060
```
