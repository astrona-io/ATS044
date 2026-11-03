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
count="$(kubectl get secrets -A --field-selector type=kubernetes.io/service-account-token -o name 2>/dev/null | wc -l | tr -d ' ')"
if [ "$count" -gt 0 ]; then
  echo "FAIL: $count Secret(s) of type kubernetes.io/service-account-token remain"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: no legacy token Secret remains"
fi
exit "$fail"
