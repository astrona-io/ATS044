---
draft: true
exam_objectives:
  - Privilege Escalation
---
# Narrowing A Role To Its Task

A role should grant what a job needs and nothing else. This part names the task, reads the rules that exist, writes a narrow replacement and proves the difference with answers from the API server.

## Start From The Task

A release job for `shuttle` has one task: set a new image on the Deployments in `starfleet`. Write down the operations that the task needs.

1. Read the Deployments: the verbs `get` and `list`.
2. Change the image: the verb `patch` on `deployments`.

Nothing in the task needs roles, bindings, pods, exec or Secrets. Each other right is surplus, and a compromised release job can use every surplus right.

The Role in the playground grants more. Read it:

<!-- astrona:playground:renew -->
```sh
kubectl get role release-manager -n starfleet -o yaml
kubectl get rolebinding release-manager -n starfleet -o yaml
```

The Role lists rules for `deployments`, `roles`, `rolebindings` and `pods/exec`. The binding gives the Role to the service account `shuttle`. List the rights of the account before the change:

```sh
kubectl auth can-i --list -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The list shows `deployments`, `roles`, `rolebindings` and `pods/exec` with their verbs, and the default rights that every authenticated identity has.

## Why The Surplus Rights Matter

Take each surplus right and follow it.

- Create on `rolebindings` lets the job bind any Role it holds the permissions of to any subject. The job can therefore hand its own rights to another identity and keep them after the job is removed.
- Create on `roles` lets the job write a new Role with permissions that it holds. With create on `rolebindings` it can bind the Role at once.
- Create on `pods/exec` lets the job run commands in every pod of the namespace. The job then reads the Secrets that those pods mount and the tokens of their service accounts.

A job that only patches Deployments has none of these routes. The change also reduces what an attacker gains who steals the token of the job.

## Write The Narrow Role

Save this as `role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: release-manager
  namespace: starfleet
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch"]
```

Apply it. The `rules` list is replaced as a whole, so the old rules are gone:

```sh
kubectl apply -f role.yaml
```

The field `apiGroups` matters. Deployments belong to the group `apps`, and the empty string names the core group that holds pods and Secrets. A rule with the wrong group silently grants nothing, or the wrong thing.

## Prove The Difference

Repeat the questions and read the answers:

```sh
kubectl auth can-i patch deployments -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create rolebindings -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create roles -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods/exec -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The first answer is `yes`. The other three are `no`. A control that is not proved with a request that must fail and a request that must work is an assumption.

## Narrower Still

A rule can name the Deployments that it covers with `resourceNames`. A rule with `resourceNames: ["scout"]` and the verb `patch` changes only the Deployment `scout`. The verbs `list` and `create` cannot be limited this way, because the request carries no name. Use a namespace for each team so that a role without names still has a small reach.

A job that runs only at release time can also hold its token only for that time. Use a short-lived token instead of a long-lived credential in a repository.

## Remove The Escalation Verbs From Everyone

Check that no ordinary role holds the verbs that move authority. Run the search for `bind`, `escalate`, `impersonate` and `*` again and compare the output with the list that you reviewed. A new line is a change that needs a reason. Keep the list in version control and review changes to roles like changes to code.

## Common Mistakes

- A wildcard `*` in the verbs, the resources or the groups grants more than anyone intended, now and for every resource that is added later.
- A ClusterRole in a RoleBinding is limited to the namespace of the binding. The same ClusterRole in a ClusterRoleBinding reaches every namespace.
- A new Role is additive. Removing one rule does not reduce authority if another binding still grants it. Always read the effective rights with `can-i --list`.
