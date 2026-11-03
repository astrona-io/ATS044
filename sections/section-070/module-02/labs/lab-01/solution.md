# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-02/labs/lab-01
```

## Step 1: Confirm the open state

Save this as `risky-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: risky
  namespace: starfleet
spec:
  containers:
    - name: risky
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
      securityContext:
        privileged: true
```

Send it with a server-side dry run. The cluster should accept it:

```sh
kubectl apply -f risky-pod.yaml --dry-run=server
```

## Step 2: Enforce the baseline

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/enforce=baseline
kubectl apply -f risky-pod.yaml --dry-run=server
```

The second command should now be rejected with a message about privileged containers. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-02/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-070/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-070-02
```
