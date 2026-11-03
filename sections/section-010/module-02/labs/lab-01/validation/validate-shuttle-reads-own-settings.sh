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
expect_can yes get configmaps/shuttle-settings -n starfleet --as="$SA"
if ! kubectl -n starfleet get configmap shuttle-settings --as="$SA" >/dev/null 2>&1; then
  echo "FAIL: a real get of shuttle-settings as shuttle was refused"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle reads shuttle-settings"
fi
exit "$fail"
