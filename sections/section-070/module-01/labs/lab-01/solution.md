# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-01/labs/lab-01
```

## Step 1: Read the effect of the Role

```sh
kubectl get role release-manager -n starfleet -o yaml
kubectl auth can-i create rolebindings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods/exec -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The Role lists rules for `deployments`, `roles`, `rolebindings` and `pods/exec`. Both answers should be `yes`. Only the rule for Deployments is part of the task.

## Step 2: Replace the Role

Save this as `role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: release-manager
  namespace: starfleet
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch"]
```

Apply it. The rules list is replaced as a whole:

```sh
kubectl apply -f role.yaml
```

## Step 3: Test the result

```sh
kubectl auth can-i patch deployments.apps -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create rolebindings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create roles -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods/exec -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The first answer should be `yes` and the other three `no`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-01/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-070-01
```
