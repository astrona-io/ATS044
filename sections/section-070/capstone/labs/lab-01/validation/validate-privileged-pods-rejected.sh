#!/usr/bin/env bash
set -uo pipefail
fail=0
# expect_can WANT ARGS...: compare the answer of `kubectl auth can-i ARGS`.
expect_can() {
  local want="$1"; shift
  local answer
  answer="$(kubectl auth can-i "$@" 2>/dev/null || true)"
  if [ "$answer" != "$want" ]; then
    echo "FAIL: kubectl auth can-i $* answered '$answer', expected '$want'"
    fail=1
  fi
}
if kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<'Y'
apiVersion: v1
kind: Pod
metadata:
  name: psa-risky
  namespace: starfleet
spec:
  containers:
    - name: risky
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
      securityContext:
        privileged: true
Y
then
  echo "FAIL: a privileged pod is still accepted in starfleet"
  fail=1
fi
if kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<'Y'
apiVersion: v1
kind: Pod
metadata:
  name: psa-hostpath
  namespace: starfleet
spec:
  containers:
    - name: hostpath
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
      volumeMounts:
        - name: host
          mountPath: /host
  volumes:
    - name: host
      hostPath:
        path: /
Y
then
  echo "FAIL: a pod with a hostPath volume is still accepted in starfleet"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: dangerous pods are rejected"
fi
exit "$fail"
