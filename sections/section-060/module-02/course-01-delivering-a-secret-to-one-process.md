---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Delivering A Secret To One Process

A Secret in the cluster database is only useful when a container receives its value. The method of delivery decides who else can read it. This part shows what each method exposes, changes the delivery of a password in a running Deployment and checks the result.

## Two Ways To Deliver A Value

A container can take a Secret value as an environment variable. The pod specification names the Secret and the key with `valueFrom.secretKeyRef`. The kubelet reads the value when it starts the container and puts it in the process environment.

A container can also mount the Secret as a volume. The kubelet writes each key as a file in a directory that is held in memory, and the container reads the file. The mount can be read-only, and the file permissions can be set with `defaultMode`.

The two methods differ in four ways.

- Environment variables are visible to any command in the container that prints the environment, and to every child process that the application starts. Many frameworks print the environment in an error page or a crash report.
- A file is read only by a process that opens it. A process that does not open the file does not receive the value.
- An environment variable never changes while the container runs. The kubelet updates a mounted file when the Secret changes, after a short delay, unless the file is mounted with `subPath`.
- A file has permissions, so the group and the mode limit which users in the container read it.

A file is the better default. An environment variable is acceptable for a value that the application cannot read from a file.

## See The Current State

<!-- astrona:playground:renew -->
The playground starts `probe` with the database password in an environment variable. Print its environment from inside the container:

```sh
kubectl exec -n starfleet deploy/probe -- env
```

The output includes a line `DB_PASSWORD=` followed by the value. Anyone who can run `exec` in this pod now holds the password. Show how the pod specification asks for it:

```sh
kubectl get deployment probe -n starfleet -o json | jq '.spec.template.spec.containers[0].env'
```

The output shows an entry named `DB_PASSWORD` with a `valueFrom.secretKeyRef` that names the Secret `report-db` and the key `password`.

## Change To A Mounted File

Save this as `probe-patch.yaml`:

```yaml
spec:
  template:
    spec:
      containers:
        - name: probe
          env: []
          volumeMounts:
            - name: report-db
              mountPath: /etc/report-db
              readOnly: true
      volumes:
        - name: report-db
          secret:
            secretName: report-db
            defaultMode: 0400
```

Apply it to the Deployment:

```sh
kubectl patch deployment probe -n starfleet --patch-file probe-patch.yaml
kubectl rollout status deployment/probe -n starfleet
```

The patch replaces the list of environment variables with an empty list and adds a volume and a mount. The rollout replaces the pod. When the rollout ends, print the environment again:

```sh
kubectl exec -n starfleet deploy/probe -- env
```

The line `DB_PASSWORD` is gone. Read the file instead:

```sh
kubectl exec -n starfleet deploy/probe -- ls -l /etc/report-db
```

The listing shows one file, `password`, which is a link into a hidden directory that the kubelet updates. The mode `0400` allows only the owner to read it. A process in the container that does not open the file never holds the password.

## Limit Who Can Read The Mount

The mounted file is still readable by a user who runs `exec` as the owner, so the mount does not replace the controls on the API. Combine the delivery method with these controls.

- Keep the Role of other identities free of `get` and `list` on this Secret.
- Do not grant `pods/exec` in the namespace to identities that do not need it.
- Set `readOnly: true` on the mount, so the container cannot change the Secret data. The volume of a Secret is always read-only for the file contents, and the flag states the intent in the specification.
- Mount the Secret only in the container that needs it. A second container in the same pod does not receive the files unless it lists the mount.

## Avoid Sending Tokens To Pods That Do Not Need Them

The service account token is a credential too. Each pod receives a token for its service account by default. A pod that never calls the Kubernetes API does not need it. Set `automountServiceAccountToken: false` in the pod specification, or on the service account, and the token file is not mounted. An attacker who runs code in the pod then has no API credential to steal.

## Check The Result

Prove the change with three checks.

1. The environment of the running container has no variable with the password.
2. The file exists at the mount path and the mount is read-only.
3. The application still runs. Check the rollout and call the application:

```sh
kubectl exec -n starfleet deploy/shuttle -- curl -s -m 5 -o /dev/null -w 'status=%{http_code}\n' http://probe/get
```

The status is `200`. A change that breaks the application is not an improvement, and a rollout that does not finish shows the mistake before users see it. Because `probe` is a test server that does not read the file, the check proves only that the pod is healthy and reachable.
