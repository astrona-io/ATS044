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
level="$(kubectl get namespace starfleet -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)"
if [ "$level" != "baseline" ] && [ "$level" != "restricted" ]; then
  echo "FAIL: pod-security.kubernetes.io/enforce on starfleet is '$level', expected baseline or restricted"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: starfleet enforces baseline or restricted"
fi
exit "$fail"
