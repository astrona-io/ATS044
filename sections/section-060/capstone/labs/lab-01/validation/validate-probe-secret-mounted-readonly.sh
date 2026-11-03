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
dep="$(kubectl get deployment probe -n starfleet -o json)"
vol="$(echo "$dep" | jq -r '[.spec.template.spec.volumes[]? | select(.secret.secretName=="report-db") | .name][0] // empty')"
if [ -z "$vol" ]; then
  echo "FAIL: probe has no volume from the Secret report-db"
  fail=1
else
  ro="$(echo "$dep" | jq -r --arg v "$vol" '[.spec.template.spec.containers[0].volumeMounts[]? | select(.name==$v) | .readOnly][0] // false')"
  if [ "$ro" != "true" ]; then
    echo "FAIL: the mount of report-db in probe is not readOnly: true"
    fail=1
  fi
fi
if ! kubectl -n starfleet rollout status deployment/probe --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment probe is not fully rolled out"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe mounts report-db read-only"
fi
exit "$fail"
