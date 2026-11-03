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
if kubectl exec -n outpost deploy/drifter -- curl -s -m 5 -o /dev/null http://scout.starfleet/healthz >/dev/null 2>&1; then
  echo "FAIL: drifter can still reach scout"
  fail=1
fi
np="$(kubectl get networkpolicy -n outpost -o json | jq -r '[.items[] | select(.spec.podSelector.matchLabels.app=="drifter") | select((.spec.policyTypes // []) | index("Egress") != null)] | length')"
if [ "${np:-0}" -lt 1 ]; then
  echo "FAIL: no NetworkPolicy in outpost selects app=drifter for Egress"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter is isolated"
fi
exit "$fail"
