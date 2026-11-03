# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-01/labs/lab-01
```

## Step 1: Find the grant

List the Roles that mention Secrets and the bindings of the namespace:

```sh
kubectl get roles -n starfleet -o yaml
kubectl get rolebindings -n starfleet -o yaml
```

The Role `shuttle-secrets` allows `get`, `list` and `watch` on every Secret, and the binding `shuttle-secrets` gives it to the service account `shuttle`. Confirm the effect:

```sh
kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The answer should be `yes`.

## Step 2: Narrow the Role

Save this as `role.yaml`:

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

Apply it. The rules list is replaced as a whole:

```sh
kubectl apply -f role.yaml
```

## Step 3: Test the result

```sh
kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secret/report-db -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secret/shuttle-token -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The first two answers should be `no` and the third should be `yes`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-01/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-060-01
```
