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
ok="$(kubectl get resourcequota -n outpost -o json | jq -r '[.items[] | select(.spec.hard.pods != null) | select(.spec.hard["limits.memory"] != null or .spec.hard["requests.memory"] != null) | select((.spec.hard.pods | tonumber) <= 6)] | length')"
if [ "${ok:-0}" -lt 1 ]; then
  echo "FAIL: no ResourceQuota in outpost limits pods to 6 or fewer and covers memory"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost has a bounded quota"
fi
exit "$fail"
