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
out="$(kubectl run quota-probe -n outpost --image=curlimages/curl:8.22.0 --dry-run=server -o json 2>&1)"
if ! echo "$out" | jq -e .spec >/dev/null 2>&1; then
  echo "FAIL: a pod without resources is rejected in outpost: $out"
  fail=1
else
  lim="$(echo "$out" | jq -r '.spec.containers[0].resources.limits.memory // empty')"
  if [ -z "$lim" ]; then
    echo "FAIL: a pod without resources gets no default memory limit in outpost"
    fail=1
  fi
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: a pod without resources gets a memory limit"
fi
exit "$fail"
