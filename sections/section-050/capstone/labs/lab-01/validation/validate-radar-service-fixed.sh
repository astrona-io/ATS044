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
eps="$(kubectl get endpoints radar -n starfleet -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null)"
if [ -z "$eps" ]; then
  echo "FAIL: the Service radar has no ready endpoints"
  fail=1
fi
port="$(kubectl get service radar -n starfleet -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)"
if [ "$port" != "80" ]; then
  echo "FAIL: the Service port is '$port'; clients use port 80"
  fail=1
fi
tp="$(kubectl get service radar -n starfleet -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)"
if [ "$tp" != "9898" ] && [ "$tp" != "http" ]; then
  echo "FAIL: the targetPort is '$tp'; the container listens on 9898 (named http)"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: radar has ready endpoints"
fi
exit "$fail"
