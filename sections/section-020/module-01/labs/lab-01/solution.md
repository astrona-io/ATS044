# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: List the controllers

List every object that starts pods, sorted by creation time:

```sh
kubectl get deployments,daemonsets,statefulsets,cronjobs -A --sort-by=.metadata.creationTimestamp
```

The four example Deployments belong to the application. The CronJob `cache-warmer` and the DaemonSet `node-helper` in `starfleet` do not.

## Step 2: Remove the CronJob and the DaemonSet

Save the CronJob as evidence first, then delete both objects:

```sh
kubectl get cronjob cache-warmer -n starfleet -o yaml > cronjob-evidence.yaml
kubectl delete cronjob cache-warmer -n starfleet
kubectl delete daemonset node-helper -n starfleet
```

Deleting a CronJob also deletes its Jobs and their pods through the owner references. Check that no pod is left:

```sh
kubectl get jobs,pods -n starfleet
```

## Step 3: Remove the cluster-admin grant

Find the binding for the service account that the CronJob used:

```sh
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(any(.subjects[]?; .name=="backup-helper")) | .metadata.name'
```

It should print `backup-helper-admin`. Delete it and check the result:

```sh
kubectl delete clusterrolebinding backup-helper-admin
kubectl auth can-i '*' '*' --as=system:serviceaccount:starfleet:backup-helper
```

The answer should be `no`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-01/labs/lab-01 --keep
```

All four checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-020-01
```
