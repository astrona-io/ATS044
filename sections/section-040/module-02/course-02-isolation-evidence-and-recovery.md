---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Isolation, Evidence And Recovery

When a workload is suspected to be compromised, two goals compete. The first is to stop damage at once. The second is to keep the evidence that explains what happened. This part shows an order that does both: restrict the network, collect what exists, and only then replace the workload with a trusted one.

## Why Deletion Comes Last

A deleted pod takes its logs and its writable layer with it. If a Deployment owns the pod, a replacement starts from the same image and the same specification, and a flawed image or a stolen credential is still in place. So deletion neither preserves evidence nor proves recovery. Isolation first keeps the pod running but unable to do harm.

## Step 1: Isolate With A NetworkPolicy

A NetworkPolicy selects pods with a label selector and lists allowed traffic. When a pod is selected by a policy for a direction, only the listed traffic is allowed in that direction. A policy with an empty rule list therefore blocks everything in that direction. A network plugin that enforces policies is required. Calico does that in this playground.

First check what `drifter` can reach now:

<!-- astrona:playground:renew -->
```sh
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://scout.starfleet/healthz
```

The command returns a response body, so the pod can reach `scout`. Save this as `networkpolicy-drifter-isolate.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: drifter-isolate
  namespace: outpost
spec:
  podSelector:
    matchLabels:
      app: drifter
  policyTypes:
    - Egress
    - Ingress
```

Apply it:

```sh
kubectl apply -f networkpolicy-drifter-isolate.yaml
```

Then repeat the request:

```sh
kubectl exec -n outpost deploy/drifter -- curl -s -m 5 http://scout.starfleet/healthz
```

The request times out after five seconds with no body. The policy has no `egress` or `ingress` rules, so it allows none. The `shuttle` pod is not selected, so it keeps reaching `scout`. Always test that the healthy workloads still work.

## Step 2: Collect Evidence

The pod still runs, so read what it holds. Save the full specification, which records the image, the user and the mounts, and save the container log:

```sh
kubectl get pod -n outpost -l app=drifter -o yaml > drifter-pod.yaml
kubectl logs -n outpost deploy/drifter > drifter.log
kubectl get events -n outpost --sort-by=.lastTimestamp > outpost-events.txt
```

Record the image digest that the node actually ran. The digest identifies the exact content, while a tag can point to different content over time:

```sh
kubectl get pod -n outpost -l app=drifter -o jsonpath='{.items[0].status.containerStatuses[0].imageID}{"\n"}'
```

On a real cluster, also gather the API audit records for the service account and any logs that the node or the application sends to central storage. Memory and disk captures need access to the node and belong to the incident process of the organisation.

## Step 3: Replace With A Trusted Workload

Recovery means a new pod from reviewed inputs. Check these before the new pod starts:

1. The image reference is a digest that the team has scanned and approved.
2. The Deployment, ConfigMaps and Secrets match the reviewed source, because an attacker with write access may have changed them.
3. Credentials that the old pod could read are rotated: tokens, database passwords and keys.
4. The service account has no roles that the workload does not need.

Then roll out the new version and check the result:

```sh
kubectl rollout restart deployment/drifter -n outpost
kubectl rollout status deployment/drifter -n outpost
kubectl get pod -n outpost -l app=drifter -o jsonpath='{.items[0].status.containerStatuses[0].imageID}{"\n"}'
```

The new line should show the approved digest. A restart alone proves nothing when the Deployment still names the compromised image, so the comparison of the digest with the approved one is the check.

## Step 4: Verify And Lift The Isolation

Verify the behaviour that matters: the workload does its job, it cannot do what it should not, and no old credential works. Only then replace the isolating policy with a narrow allow rule that lists the destinations that the workload needs. Keep the evidence files until the review ends.

## When The Node Is In Doubt

If the container had a host path, a runtime socket or privileged mode, the attacker may have affected the node. Replacing the pod does not clean a node. Cordon the node, drain it and rebuild it from a trusted image, as described by the incident process, and rotate the credentials that were on it.

## Common pitfalls

> [!WARNING]
> A NetworkPolicy without a network plugin that enforces it does nothing and gives no error. Test the isolation with a real request, and do not rely on the object existing.
