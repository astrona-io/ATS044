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
kubectl -n starfleet rollout status deployment/shuttle --timeout=120s >/dev/null 2>&1 || { echo "FAIL: shuttle is not rolled out"; fail=1; }
uid="$(kubectl exec -n starfleet deploy/shuttle -- id -u 2>/dev/null || echo err)"
if [ "$uid" = "0" ] || [ "$uid" = "err" ]; then
  echo "FAIL: the process of shuttle runs as user '$uid' (expected a non-zero user)"
  fail=1
fi
if kubectl exec -n starfleet deploy/shuttle -- sh -c 'touch /tmp/ro-test' >/dev/null 2>&1; then
  echo "FAIL: the root file system of shuttle is writable"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle runs as non-root with a read-only root file system"
fi
exit "$fail"
