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
ok="$(kubectl get limitrange -n outpost -o json | jq -r '[.items[].spec.limits[] | select(.type=="Container") | select(.default.memory != null and .defaultRequest.memory != null)] | length')"
if [ "${ok:-0}" -lt 1 ]; then
  echo "FAIL: no LimitRange in outpost sets a default memory limit and request for containers"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost has default memory values"
fi
exit "$fail"
