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
SA="system:serviceaccount:outpost:drifter"
expect_can no list pods --all-namespaces --as="$SA"
expect_can no list pods -n starfleet --as="$SA"
expect_can no get secrets -n starfleet --as="$SA"
if ! kubectl get serviceaccount drifter -n outpost >/dev/null 2>&1; then
  echo "FAIL: the service account drifter was deleted"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter has no cluster-wide read"
fi
exit "$fail"
