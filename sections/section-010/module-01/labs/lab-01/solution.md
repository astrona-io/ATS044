# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Find the token mount

A pod gets its token from a projected volume named `kube-api-access-<suffix>`. Check one pod:

```sh
kubectl get pods -n starfleet -l app=shuttle -o jsonpath='{.items[0].spec.volumes[*].name}'
```

The output should contain a name that starts with `kube-api-access`. The field that stops the mount is `automountServiceAccountToken` in the pod template.

## Step 2: Patch the Deployments in starfleet

Save this as `patch-no-token.yaml`:

```yaml
spec:
  template:
    spec:
      automountServiceAccountToken: false
```

Apply it to each Deployment:

```sh
for name in scout probe shuttle; do
  kubectl patch deployment "$name" -n starfleet --patch-file patch-no-token.yaml
done
kubectl patch deployment drifter -n outpost --patch-file patch-no-token.yaml
```

The patch changes the pod template, so each Deployment starts a new pod and removes the old one. Wait for the rollouts:

```sh
for name in scout probe shuttle; do
  kubectl rollout status deployment/"$name" -n starfleet
done
kubectl rollout status deployment/drifter -n outpost
```

## Step 3: Check and grade

Check that no pod mounts the token volume:

```sh
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" "}{.spec.volumes[*].name}{"\n"}{end}'
```

The `starfleet` and `outpost` pods should show no `kube-api-access` volume. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-01/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-010/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-010-01
```
