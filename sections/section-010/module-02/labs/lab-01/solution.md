# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: See the current grant

Check what the service account can do now:

```sh
kubectl auth can-i --list -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The list should show `get`, `list` and `watch` on `configmaps` and `secrets`. The Role `shuttle-reader` holds these rules.

## Step 2: Narrow the Role

A rule can name objects with `resourceNames`. Such a rule works for `get`, `update`, `patch` and `delete`. It does not work for `list`, `watch` or `create`, because the request does not name an object. Save this as `role-shuttle-reader.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: shuttle-reader
  namespace: starfleet
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["shuttle-settings"]
    verbs: ["get"]
```

Apply it. The RoleBinding still points at the Role name, so the binding does not change:

```sh
kubectl apply -f role-shuttle-reader.yaml
```

## Step 3: Check and grade

Check the allowed read and three refusals:

```sh
kubectl auth can-i get configmaps/shuttle-settings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get configmaps/other-settings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i list configmaps -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The first answer should be `yes` and the other three `no`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-02/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-010-02
```
