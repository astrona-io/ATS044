---
draft: true
exam_objectives:
  - Access to Sensitive Data
---
# Rotating And Revoking A Credential

A credential is exposed sooner or later, so a design must allow a fast and safe change of the value. This part rotates the password in the Secret, shows when a running pod sees the new value and lists what revocation does and does not recover.

## What Rotation Needs

A rotation has four steps and all four must happen.

1. Create the new value at the issuer, which is the database or the service that accepts the credential.
2. Store the new value in the Secret.
3. Make every consumer use the new value.
4. Revoke the old value at the issuer.

Changing only the Secret does not rotate anything. The issuer still accepts the old value, and a pod that holds the old value in its environment keeps it. The old value works until the issuer revokes it. Order matters as well. If you revoke the old value before the consumers change, the application fails. A common method keeps both values valid for a short overlap, moves the consumers and then revokes the old value.

## Change The Secret

<!-- astrona:playground:renew -->
In this playground `probe` reads the password from an environment variable. Change the value of the Secret. The `stringData` field accepts plain text and the API server stores it as base64:

```sh
kubectl patch secret report-db -n starfleet --type=merge -p '{"stringData":{"password":"new-orbit-9001"}}'
kubectl get secret report-db -n starfleet -o jsonpath='{.data.password}' | base64 -d; echo
```

The second command prints the new value. Now read the environment of the running pod:

```sh
kubectl exec -n starfleet deploy/probe -- env
```

The line `DB_PASSWORD` still holds the old value. The kubelet read the Secret when it started the container, and an environment variable does not change afterwards. The Secret is new and the process is old.

## Make The Consumer Use The New Value

Restart the pods so that the kubelet reads the Secret again:

```sh
kubectl rollout restart deployment/probe -n starfleet
kubectl rollout status deployment/probe -n starfleet
kubectl exec -n starfleet deploy/probe -- env
```

The new pod holds the new value. A Deployment replaces its pods one at a time, so the service stays available when it has more than one replica.

A mounted file behaves differently. The kubelet checks the Secret regularly and rewrites the file when the value changes, usually within about a minute. The application sees the new file contents only if it reads the file again. An application that reads the file once at start up still needs a restart. A file mounted with `subPath` is never updated by the kubelet.

## Immutable Secrets

A Secret can be marked `immutable: true`. The API server then rejects any change of its data, and the kubelet stops watching it, which lowers the load on the API server. To change the value, create a new Secret with a new name and update the Deployment to use it. The rollout then replaces the pods in a controlled way, and the old Secret can be deleted when no pod uses it.

## What Revocation Recovers

Revocation at the issuer stops all later use of the old value. It does not undo what was done while the value was valid. After an exposure, answer three questions.

- When was the value exposed and when was it revoked? The difference is the window of risk.
- What did the credential allow in that window? A read-only credential limits the damage to disclosure, and a write credential allows changes.
- Where are the records of use? The logs of the issuer show which addresses used the credential.

A confidential report that was read is read. Revocation prevents a second read and does not remove the first copy. Communication with the affected people follows the facts that the records show.

## Check The Whole Path

Use this list after every rotation.

- The issuer rejects the old value. Test it with a request that uses the old value.
- The Secret holds the new value.
- Every pod that uses the Secret holds the new value, by environment or by file.
- No old copy is in a place that you can still change, such as a ConfigMap, a manifest in a repository or a script.

## Plan The Next Rotation

A rotation done in a hurry during an incident often breaks the application. Practise it when nothing is wrong. Keep the issuer able to hold two values at once, keep the consumers able to reload a file, and record the commands. A rotation that you have done ten times is routine, and a rotation that you do for the first time during an incident is a risk of its own.

## Test A Change Of A Mounted File

If a pod mounts the Secret as a file, you can watch the kubelet update it. Mount the Secret, change its value and read the file in a loop:

```sh
kubectl exec -n starfleet deploy/probe -- cat /etc/report-db/password
```

Run the command every ten seconds after you patch the Secret. The old value is printed until the kubelet syncs the volume, which usually takes less than a minute, and then the new value is printed. The delay exists because the kubelet checks for changes on a timer. For a rotation, plan for that delay and do not revoke the old value before every pod shows the new file.

## Use Short Lived Credentials When The Issuer Allows It

The simplest rotation is a credential that expires by itself. A token that is valid for one hour has to be renewed every hour, so a stolen copy is useless soon. Service account tokens that the kubelet projects into a pod work this way. They have an expiry time and the kubelet renews them before they expire. An external system that can issue short lived credentials removes most of the work of rotation, because there is no old value to revoke and no long window of risk.
