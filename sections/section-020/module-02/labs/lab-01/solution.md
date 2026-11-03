# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Find and remove the legacy token

Search for Secrets of the legacy type:

```sh
kubectl get secrets -n starfleet --field-selector type=kubernetes.io/service-account-token
```

The list should show `ci-runner-token`. Delete it. The service account stays:

```sh
kubectl delete secret ci-runner-token -n starfleet
```

## Step 2: Remove the host path workload

Find the pods with a `hostPath` volume:

```sh
kubectl get pods -n starfleet -o json | jq -r '.items[] | select(any(.spec.volumes[]?; .hostPath != null)) | .metadata.name'
```

The pod belongs to the Deployment `node-agent`. Delete the Deployment, not only the pod:

```sh
kubectl delete deployment node-agent -n starfleet
```

## Step 3: Enforce the baseline level

Label the namespace. Because no pod violates `baseline` any more, the change is clean:

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline --overwrite
kubectl get namespace starfleet --show-labels
```

The labels should include `pod-security.kubernetes.io/enforce=baseline`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-02/labs/lab-01 --keep
```

All four checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-020/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-020-02
```
