# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/capstone/labs/lab-01
```

## Step 1: Narrow the Role

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

Apply it and test the answers. The first should be `yes` and the other three `no`:

```sh
kubectl apply -f role.yaml
kubectl auth can-i patch deployments.apps -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create rolebindings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create roles -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods/exec -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

Grade this step:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/capstone/labs/lab-01 --keep
```

## Step 2: Enforce the baseline

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline
```

Test a privileged pod with a server-side dry run. The cluster should reject it:

```sh
kubectl run risky --image=curlimages/curl:8.22.0 -n starfleet --privileged --dry-run=server -- sleep 3600
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/capstone/labs/lab-01 --keep
```

All five checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-070
```
