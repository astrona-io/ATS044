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
SA="system:serviceaccount:starfleet:shuttle"
expect_can no get configmaps/other-settings -n starfleet --as="$SA"
expect_can no list configmaps -n starfleet --as="$SA"
expect_can no get secrets -n starfleet --as="$SA"
expect_can no list secrets -n starfleet --as="$SA"
expect_can no get configmaps/shuttle-settings -n outpost --as="$SA"
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle is limited to one ConfigMap"
fi
exit "$fail"
