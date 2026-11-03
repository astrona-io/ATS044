# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Remove the CronJob and its authority

List the controllers and find the CronJob, then find the binding of its service account:

```sh
kubectl get cronjobs -A
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(any(.subjects[]?; .name=="backup-helper")) | .metadata.name'
```

Delete the CronJob and the binding:

```sh
kubectl delete cronjob cache-warmer -n starfleet
kubectl delete clusterrolebinding backup-helper-admin
```

## Step 2: Remove the legacy token

Search all namespaces and delete what you find:

```sh
kubectl get secrets -A --field-selector type=kubernetes.io/service-account-token
kubectl delete secret shuttle-legacy-token -n starfleet
```

## Step 3: Remove the host path workload and enforce baseline

Find the pod that mounts a host path, delete its Deployment and label the namespace:

```sh
kubectl get pods -A -o json | jq -r '.items[] | select(.metadata.namespace=="outpost") | select(any(.spec.volumes[]?; .hostPath != null)) | .metadata.name'
kubectl delete deployment node-agent -n outpost
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline --overwrite
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/capstone/labs/lab-01 --keep
```

All five checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/capstone/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-capstone-020
```
