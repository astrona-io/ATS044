---
draft: true
exam_objectives:
  - Malicious Code Execution and Compromised Applications in Containers
---
# Hardening The Container Boundary

A hardened container does less for an attacker even when the application code is flawed. The settings live in the `securityContext` field of the pod and of each container, and Pod Security Admission can require them for a whole namespace. This part sets each field on `drifter` and proves the effect with commands that fail after the change.

## The Fields And What They Remove

- `runAsNonRoot: true` makes the kubelet refuse to start a container whose user is root. It needs a numeric user, either from the image or from `runAsUser`.
- `runAsUser` sets the numeric user ID. A non-root user cannot write to most system paths or bind low ports.
- `allowPrivilegeEscalation: false` sets the Linux flag `no_new_privs`. A process can no longer gain privileges through a set-user-ID program.
- `capabilities.drop: ["ALL"]` removes every Linux capability from the container. An application adds back only the one it needs, such as `NET_BIND_SERVICE`.
- `readOnlyRootFilesystem: true` mounts the root file system read-only. Writable data goes to a volume.
- `seccompProfile.type: RuntimeDefault` applies the container runtime's default system-call filter.
- `privileged: false` is the default, and it keeps host devices and all capabilities out of the container.

## Look At The Starting State

<!-- astrona:playground:renew -->
Read the current security context of `drifter` and test what its process can do:

```sh
kubectl get deployment drifter -n outpost -o jsonpath='{.spec.template.spec.containers[0].securityContext}{"\n"}'
kubectl exec -n outpost deploy/drifter -- sh -c 'touch /tmp/x && echo writable'
```

The first command prints an empty line because no security context is set. The second prints `writable`. The container runs with the defaults of the image and the runtime.

## Apply The Settings

The curl image defines its user by name, which `runAsNonRoot` cannot check, so set a numeric user. Save this as `drifter-hardened.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: drifter
  namespace: outpost
  labels:
    app: drifter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drifter
  template:
    metadata:
      labels:
        app: drifter
    spec:
      serviceAccountName: drifter
      automountServiceAccountToken: false
      containers:
        - name: drifter
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
          securityContext:
            runAsNonRoot: true
            runAsUser: 10001
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
            seccompProfile:
              type: RuntimeDefault
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
            limits:
              memory: 32Mi
```

Apply it and wait for the new pod:

```sh
kubectl apply -f drifter-hardened.yaml
kubectl rollout status deployment/drifter -n outpost
```

Then check the result from inside the new pod:

```sh
kubectl exec -n outpost deploy/drifter -- id -u
kubectl exec -n outpost deploy/drifter -- sh -c 'touch /tmp/x && echo writable'
```

The user ID is `10001`. The write fails with a message that the file system is read-only. The container still runs its loop, so the application function stays. A real application that writes logs or temporary files needs an `emptyDir` volume mounted at that path.

## Pod Security Admission

Writing every field by hand does not scale. Pod Security Admission is a built-in admission controller that checks each new pod in a namespace against one of three levels. `privileged` allows everything. `baseline` blocks the known privilege escalations, such as privileged containers, host namespaces and host paths. `restricted` follows the current hardening practice and also requires non-root, dropped capabilities and a seccomp profile. A namespace label chooses the level and the mode:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/warn=restricted --overwrite
```

The mode `warn` prints a warning for a pod that would fail. The mode `enforce` rejects it, and `audit` writes an audit annotation. Use `warn` first to find which workloads would fail, and then `enforce` when the list is empty. Test the effect with a server-side dry run of a pod that sets nothing:

```sh
kubectl run test-pod -n outpost --image=curlimages/curl:8.22.0 --dry-run=server -o name
```

The response carries a warning that lists the fields that break the `restricted` level, such as `allowPrivilegeEscalation` and `runAsNonRoot`.

## What Hardening Does Not Do

The settings do not remove the application flaw. They remove the attacker's easy next steps. A process with all of them set still uses the data and network paths that it legitimately has. A kernel vulnerability reachable through the permitted system calls is still an escape path, which is why the sandbox choice and node patching stay in the model.

## Common pitfalls

> [!WARNING]
> `runAsNonRoot: true` without a numeric user fails with `CreateContainerConfigError` when the image names its user. Also, `readOnlyRootFilesystem: true` breaks applications that write to `/tmp` until a volume is mounted there.
