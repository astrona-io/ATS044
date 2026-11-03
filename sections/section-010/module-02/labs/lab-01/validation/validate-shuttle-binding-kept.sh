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
if ! kubectl get serviceaccount shuttle -n starfleet >/dev/null 2>&1; then
  echo "FAIL: the service account shuttle was deleted"
  fail=1
fi
count="$(kubectl get rolebindings -n starfleet -o json | jq '[.items[] | select(any(.subjects[]?; .kind=="ServiceAccount" and .name=="shuttle"))] | length')"
if [ "$count" -lt 1 ]; then
  echo "FAIL: no RoleBinding names the shuttle service account"
  fail=1
fi
if ! kubectl -n starfleet rollout status deployment/shuttle --timeout=60s >/dev/null 2>&1; then
  echo "FAIL: the shuttle Deployment is not available"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle is still bound and running"
fi
exit "$fail"
