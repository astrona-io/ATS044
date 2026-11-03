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
if ! kubectl exec -n starfleet deploy/shuttle -- curl -sf -m 6 -o /dev/null http://scout/healthz >/dev/null 2>&1; then
  echo "FAIL: shuttle cannot reach scout"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle reaches scout"
fi
exit "$fail"
