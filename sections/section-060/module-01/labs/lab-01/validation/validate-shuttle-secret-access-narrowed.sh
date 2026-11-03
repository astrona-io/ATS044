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
can() { kubectl auth can-i "$@" --as="$sa" 2>/dev/null || true; }
if [ "$(can list secrets -n starfleet)" = "yes" ]; then
  echo "FAIL: shuttle can still list Secrets in starfleet"
  fail=1
fi
if [ "$(can get secret/report-db -n starfleet)" = "yes" ]; then
  echo "FAIL: shuttle can still read the Secret report-db"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle cannot list Secrets or read report-db"
fi
exit "$fail"
