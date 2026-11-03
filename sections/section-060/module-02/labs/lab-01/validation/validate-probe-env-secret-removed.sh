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
n="$(kubectl get deployment probe -n starfleet -o json | jq '[.spec.template.spec.containers[].env[]? | select(.valueFrom.secretKeyRef != null)] | length')"
if [ "${n:-1}" -ne 0 ]; then
  echo "FAIL: probe still takes a value from a Secret through an environment variable"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has no Secret environment variable"
fi
exit "$fail"
