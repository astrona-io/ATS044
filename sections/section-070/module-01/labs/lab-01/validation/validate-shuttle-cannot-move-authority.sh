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
if [ "$(can create rolebindings -n starfleet)" = "yes" ]; then
  echo "FAIL: shuttle can still create role bindings in starfleet"
  fail=1
fi
if [ "$(can create roles -n starfleet)" = "yes" ]; then
  echo "FAIL: shuttle can still create roles in starfleet"
  fail=1
fi
if [ "$(can create pods/exec -n starfleet)" = "yes" ]; then
  echo "FAIL: shuttle can still run commands in pods in starfleet"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle cannot move authority"
fi
exit "$fail"
