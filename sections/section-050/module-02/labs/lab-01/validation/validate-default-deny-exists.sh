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
n="$(kubectl get networkpolicy -n starfleet -o json | jq -r '[.items[] | select((.spec.podSelector // {}) == {}) | select((.spec.policyTypes // []) | index("Ingress") != null) | select((.spec.ingress // []) | length == 0)] | length')"
if [ "${n:-0}" -lt 1 ]; then
  echo "FAIL: no default-deny ingress policy (podSelector {} with no ingress rules) exists in starfleet"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: a default-deny ingress policy exists"
fi
exit "$fail"
