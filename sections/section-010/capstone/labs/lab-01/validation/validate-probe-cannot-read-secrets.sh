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
SA="system:serviceaccount:starfleet:probe"
expect_can no get secrets -n starfleet --as="$SA"
expect_can no list secrets -n starfleet --as="$SA"
if ! kubectl get serviceaccount probe -n starfleet >/dev/null 2>&1; then
  echo "FAIL: the service account probe was deleted"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has no Secret access"
fi
exit "$fail"
