# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Remove the cluster-wide read from drifter

Find the binding that names the service account:

```sh
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(any(.subjects[]?; .kind=="ServiceAccount" and .name=="drifter")) | .metadata.name'
```

The command should print `drifter-view`. Delete that ClusterRoleBinding and keep the service account:

```sh
kubectl delete clusterrolebinding drifter-view
kubectl auth can-i list pods --all-namespaces --as=system:serviceaccount:outpost:drifter
```

The check should answer `no`.

## Step 2: Remove the token from shuttle

Save this as `patch-no-token.yaml`:

```yaml
spec:
  template:
    spec:
      automountServiceAccountToken: false
```

Apply it and wait for the rollout:

```sh
kubectl patch deployment shuttle -n starfleet --patch-file patch-no-token.yaml
kubectl rollout status deployment/shuttle -n starfleet
```

## Step 3: Remove the Secret access from probe

List the bindings of `probe` and delete the one that grants Secrets:

```sh
kubectl get rolebindings -n starfleet -o wide
kubectl delete rolebinding probe-secrets -n starfleet
kubectl delete role probe-secrets -n starfleet
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:probe
```

The last command should answer `no`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/capstone/labs/lab-01 --keep
```

All four checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-010
```
