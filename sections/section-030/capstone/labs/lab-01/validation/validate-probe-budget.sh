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
ok="$(kubectl get pdb -n starfleet -o json | jq -r '[.items[] | select(.spec.selector.matchLabels.app=="probe") | select(.status.disruptionsAllowed >= 1)] | length')"
if [ "${ok:-0}" -lt 1 ]; then
  echo "FAIL: no PodDisruptionBudget for app=probe in starfleet allows at least one disruption (needs two ready replicas and minAvailable 1)"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has a usable budget"
fi
exit "$fail"
