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
if kubectl get cronjob cache-warmer -n starfleet >/dev/null 2>&1; then
  echo "FAIL: the CronJob cache-warmer still exists"
  fail=1
fi
jobs="$(kubectl get jobs -n starfleet -o name 2>/dev/null | grep -c cache-warmer || true)"
if [ "$jobs" -gt 0 ]; then
  echo "FAIL: $jobs Job(s) from cache-warmer still exist"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: cache-warmer and its Jobs are gone"
fi
exit "$fail"
