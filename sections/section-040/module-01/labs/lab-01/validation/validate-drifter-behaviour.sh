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
kubectl -n outpost rollout status deployment/drifter --timeout=120s >/dev/null 2>&1 || { echo "FAIL: drifter is not rolled out"; fail=1; }
uid="$(kubectl exec -n outpost deploy/drifter -- id -u 2>/dev/null || echo err)"
if [ "$uid" = "0" ] || [ "$uid" = "err" ]; then
  echo "FAIL: the process of drifter runs as user '$uid' (expected a non-zero user)"
  fail=1
fi
if kubectl exec -n outpost deploy/drifter -- sh -c 'touch /tmp/ro-test' >/dev/null 2>&1; then
  echo "FAIL: the root file system of drifter is writable"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter runs as non-root with a read-only root file system"
fi
exit "$fail"
