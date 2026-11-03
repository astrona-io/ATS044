# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-02/labs/lab-01
```

## Step 1: Confirm the problem

```sh
kubectl exec -n starfleet deploy/probe -- env
```

The output should include the line `DB_PASSWORD=` with the password.

## Step 2: Change the delivery

Remove the variable and add the volume and the read-only mount in one patch:

```sh
kubectl patch deployment probe -n starfleet --type=json -p '[{"op":"remove","path":"/spec/template/spec/containers/0/env"},{"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"report-db","mountPath":"/etc/report-db","readOnly":true}]},{"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"report-db","secret":{"secretName":"report-db","defaultMode":256}}]}]'
kubectl rollout status deployment/probe -n starfleet --timeout=120s
```

The mode 256 in the patch is the decimal form of the octal mode 0400. Wait for the rollout to end.

## Step 3: Test the result

```sh
kubectl exec -n starfleet deploy/probe -- env
kubectl exec -n starfleet deploy/probe -- ls -l /etc/report-db
```

The environment should hold no `DB_PASSWORD` line, and the directory should list the file `password`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-02/labs/lab-01 --keep
```

All three checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-060/module-02/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-060-02
```
