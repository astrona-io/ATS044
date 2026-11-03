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
if ! kubectl get flowschema importer-flow -o json >/tmp/fs.json 2>/dev/null; then
  echo "FAIL: the FlowSchema importer-flow does not exist"
  fail=1
else
  lvl="$(jq -r '.spec.priorityLevelConfiguration.name' /tmp/fs.json)"
  prec="$(jq -r '.spec.matchingPrecedence' /tmp/fs.json)"
  has="$(jq -r '[.spec.rules[]?.subjects[]? | select(.kind=="ServiceAccount" and .serviceAccount.name=="batch-importer" and .serviceAccount.namespace=="starfleet")] | length' /tmp/fs.json)"
  if [ "$lvl" != "importer-limited" ]; then echo "FAIL: priority level is '$lvl', expected importer-limited"; fail=1; fi
  if [ "$has" -lt 1 ]; then echo "FAIL: no rule matches the service account batch-importer in starfleet"; fail=1; fi
  if [ "$prec" -lt 1000 ] || [ "$prec" -gt 9000 ]; then echo "FAIL: matchingPrecedence is $prec, expected 1000 to 9000"; fail=1; fi
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: importer-flow matches batch-importer"
fi
exit "$fail"
