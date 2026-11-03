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
json="$(kubectl get pods -n starfleet -l app=shuttle -o json)"
total="$(echo "$json" | jq '[.items[] | select(.metadata.deletionTimestamp==null)] | length')"
bad="$(echo "$json" | jq -r '.items[] | select(.metadata.deletionTimestamp==null) | select(any(.spec.volumes[]?; .name|startswith("kube-api-access"))) | .metadata.name')"
if [ "$total" -lt 1 ]; then
  echo "FAIL: no running shuttle pod"
  fail=1
fi
if [ -n "$bad" ]; then
  echo "FAIL: these shuttle pods still mount a token: $bad"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle mounts no token"
fi
exit "$fail"
