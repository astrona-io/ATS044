---
draft: true
exam_objectives:
  - Persistence
---
# Finding And Removing Persistent Objects

After a compromise, the first question is which objects the attacker created or changed with the stolen authority. The answer decides what to delete. Deleting a pod, a node or a whole namespace without that answer leaves the attacker's other objects in place, and the controllers rebuild what was deleted.

This part uses a fixed search order. It goes from objects that start code, to objects that grant authority, to objects that change what the API accepts.

## Step One: Objects That Start Code

Workload controllers are the most direct form of persistence, because they run the attacker's image again and again. Use the same listing as before, across all namespaces:

<!-- astrona:playground:renew -->
```sh
kubectl get deployments,daemonsets,statefulsets,cronjobs -A -o wide
```

The `-o wide` option adds the image column. Read each image name. A name that does not match your registry, a tag such as `latest` and a digest you do not recognise are all reasons to look closer. Then read one suspicious object in full:

```sh
kubectl get cronjob <NAME> -n <NAMESPACE> -o yaml
```

Look at `schedule`, the container `command`, `serviceAccountName`, mounted volumes and `securityContext`. The service account tells you which authority the job uses.

To remove a controller, delete the controller and not its pods. Deleting a CronJob also deletes its Jobs and their pods through the owner references:

```sh
kubectl delete cronjob <NAME> -n <NAMESPACE>
```

## Step Two: Objects That Grant Authority

An attacker who cannot keep a workload alive can still keep a permission. Search the bindings for powerful roles and for subjects you do not know. This command lists every ClusterRoleBinding to `cluster-admin`; it needs `jq`:

```sh
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name=="cluster-admin") | .metadata.name + "  " + ([.subjects[]? | .kind + ":" + (.namespace // "") + "/" + .name] | join(", "))'
```

On a kind cluster, the bindings `cluster-admin` and `kubeadm:cluster-admins` belong to the platform. Any other row is a finding. Check namespaced grants too:

```sh
kubectl get rolebindings -A -o wide
```

A binding is cheap to create and easy to miss, because it holds no code. It also survives every pod deletion and every image rebuild.

## Step Three: Objects That Change What The API Accepts

The third group changes how the cluster treats later requests. A mutating admission webhook can modify every new pod, for example by adding a sidecar container. Check which webhooks exist:

```sh
kubectl get mutatingwebhookconfigurations,validatingwebhookconfigurations
```

A webhook that points to an unknown Service, or one with a `failurePolicy: Ignore`, deserves a look. Also check custom resource definitions and the controllers that act on them. A new CRD with its own controller creates a second control loop that you did not plan.

## Deciding What To Remove

Use three tests before you delete an object. Does your source of truth, such as a Git repository, contain it? Who created it, according to audit logs or the `managedFields` of the object? Does anything legitimate depend on it? An object that fails the first test and the second is a candidate for removal. An object that is both unknown and in use needs the owner's confirmation first.

Save the object as a file before you delete it, so the evidence stays available:

```sh
kubectl get cronjob <NAME> -n <NAMESPACE> -o yaml > cronjob-evidence.yaml
```

## Restoring From The Source Of Truth

Deleting bad objects is half of recovery. The other half is making sure that the good state, and only the good state, is applied. If a GitOps tool reconciles the cluster from a repository, check the repository first. A controller that reads a compromised repository restores the attacker's objects after you delete them.

The recovery sequence is: stop the access path, save evidence, remove the unknown objects, rotate the credentials the attacker could read and re-apply the reviewed manifests. The part is complete when you can run the three searches and say which one found which kind of object.

## Worked Example: Reading A Suspicious CronJob

Suppose the listing shows a CronJob named `cache-warmer` that no pipeline created. The command `kubectl get cronjob cache-warmer -n starfleet -o yaml` shows `schedule: "*/1 * * * *"`, a `curlimages/curl` container and the service account `backup-helper`. Three facts follow. The job runs every minute, so it is active, not dormant. The image is generic, so it can run any command the YAML gives it. The service account is a separate identity, so the next search is for the bindings of `backup-helper`.

The binding search shows that `backup-helper` is bound to `cluster-admin`. With that grant, the job can create any object in the cluster. The responder now knows to check for other objects created by that service account. The audit log is the best source, and `kubectl get <kind> -A --sort-by=.metadata.creationTimestamp` is a quick approximation when no audit log exists.

Removal follows the dependency order. Delete the binding first, so the identity loses authority at once. Delete the CronJob next, so no new Job starts. Then delete the service account, if nothing legitimate uses it.

## What The Search Cannot See

These commands read the live API. They do not show an object that was created and deleted, a change made to an existing object, or a file written inside a container. To see history, you need audit logs, which record who sent which request. To see changes, compare each object with the manifest in your repository. A search with `kubectl` finds objects that exist now, and it is a good first step, not a complete investigation.

## Common pitfalls

> [!WARNING]
> Deleting the pod, the node or the namespace of a suspicious workload does not remove the controller that creates it or the binding that authorizes it. Also, a CronJob that runs once a day can look idle for hours, so a search for running pods does not find it.
