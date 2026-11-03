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
bad="$(kubectl get pods -n starfleet -o json | jq -r '.items[] | select(.metadata.deletionTimestamp==null) | select(any(.spec.volumes[]?; .hostPath != null)) | .metadata.name')"
if [ -n "$bad" ]; then
  echo "FAIL: these pods still mount a host path: $bad"
  fail=1
fi
if kubectl get deployment node-agent -n starfleet >/dev/null 2>&1; then
  echo "FAIL: the Deployment node-agent still exists"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: no hostPath volume in starfleet"
fi
exit "$fail"
