# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested, so the walkthrough names what each command should do and does not show captured output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-01/labs/lab-01
```

## Step 1: Find the failing stage

Send the request from `shuttle` and read the exit code, then look at the endpoints:

```sh
kubectl exec -n starfleet deploy/shuttle -- sh -c 'curl -sS -m 5 -o /dev/null http://radar/healthz; echo "exit=$?"'
kubectl get endpoints radar -n starfleet
```

The name resolves, so the failure is not in DNS. The endpoints list should be empty, which means that no ready pod matches the selector.

## Step 2: Correct the selector

Compare the Service selector with the labels of the pods:

```sh
kubectl get service radar -n starfleet -o jsonpath='{.spec.selector}{"\n"}'
kubectl get pods -n starfleet --show-labels
```

The selector asks for `app=radar-v2`, while the pod has `app=radar`. Patch the Service:

```sh
kubectl patch service radar -n starfleet --type=merge -p '{"spec":{"selector":{"app":"radar"}}}'
kubectl get endpoints radar -n starfleet
```

The endpoints should now list one address.

## Step 3: Correct the target port

The container listens on 9898, but the Service forwards to 8080. Patch the port:

```sh
kubectl patch service radar -n starfleet --type=json -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":9898}]'
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 http://radar/healthz
```

The request should return a short JSON status. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-01/labs/lab-01 --keep
```

Both checks should pass.

Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS044.git -c sections/section-050/module-01/labs/lab-01
```

All checks should pass. Finally remove the lab:

```sh
astrona destroy ats-044-lab-050-01
```
