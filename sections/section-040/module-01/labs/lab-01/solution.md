# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-01/labs/lab-01
```

## Step 1: Read the starting state

Read the container's security context and test a write. The context should be empty and the write should work:

```sh
kubectl get deployment drifter -n outpost -o jsonpath='{.spec.template.spec.containers[0].securityContext}{"\n"}'
kubectl exec -n outpost deploy/drifter -- sh -c 'touch /tmp/x && echo writable'
```

## Step 2: Patch the container

Patch the container with a JSON patch that adds the `securityContext` field:

```sh
kubectl patch deployment drifter -n outpost --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/securityContext","value":{"runAsNonRoot":true,"runAsUser":10001,"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]'
kubectl rollout status deployment/drifter -n outpost
```

The Deployment starts a new pod with the new settings.

## Step 3: Prove the behaviour

The user ID should be `10001` and the write should fail with a read-only message:

```sh
kubectl exec -n outpost deploy/drifter -- id -u
kubectl exec -n outpost deploy/drifter -- sh -c 'touch /tmp/x && echo writable'
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-01/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-040/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-040-01
```
