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
for target in starfleet/scout starfleet/probe starfleet/shuttle outpost/drifter; do
  ns="${target%%/*}"
  name="${target##*/}"
  if ! kubectl -n "$ns" rollout status "deployment/$name" --timeout=60s >/dev/null 2>&1; then
    echo "FAIL: deployment $name in $ns is not fully rolled out"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "PASS: the example Deployments are available"
fi
exit "$fail"
