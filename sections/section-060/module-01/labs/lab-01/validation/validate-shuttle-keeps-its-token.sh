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
sa="system:serviceaccount:starfleet:shuttle"
if [ "$(kubectl auth can-i get secret/shuttle-token -n starfleet --as="$sa" 2>/dev/null || true)" != "yes" ]; then
  echo "FAIL: shuttle can no longer read its own Secret shuttle-token"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle can read shuttle-token"
fi
exit "$fail"
