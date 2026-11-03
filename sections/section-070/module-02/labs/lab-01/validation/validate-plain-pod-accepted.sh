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
if ! kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<'Y'
apiVersion: v1
kind: Pod
metadata:
  name: psa-plain
  namespace: starfleet
spec:
  containers:
    - name: plain
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
Y
then
  echo "FAIL: a plain pod is rejected in starfleet; enforce the baseline level, not a stricter one"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: a plain pod is accepted"
fi
exit "$fail"
