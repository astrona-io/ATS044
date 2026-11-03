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
if ! kubectl get prioritylevelconfiguration exporter-limited -o json >/tmp/plc.json 2>/dev/null; then
  echo "FAIL: the PriorityLevelConfiguration exporter-limited does not exist"
  fail=1
else
  t="$(jq -r '.spec.type' /tmp/plc.json)"
  r="$(jq -r '.spec.limited.limitResponse.type // empty' /tmp/plc.json)"
  s="$(jq -r '.spec.limited.nominalConcurrencyShares // 0' /tmp/plc.json)"
  if [ "$t" != "Limited" ]; then echo "FAIL: type is '$t', expected Limited"; fail=1; fi
  if [ "$r" != "Reject" ]; then echo "FAIL: limitResponse.type is '$r', expected Reject"; fail=1; fi
  if [ "$s" -gt 10 ] || [ "$s" -lt 1 ]; then echo "FAIL: nominalConcurrencyShares is $s, expected 1 to 10"; fail=1; fi
fi
if ! kubectl get flowschema exporter-flow -o json >/tmp/fs.json 2>/dev/null; then
  echo "FAIL: the FlowSchema exporter-flow does not exist"
  fail=1
else
  lvl="$(jq -r '.spec.priorityLevelConfiguration.name' /tmp/fs.json)"
  prec="$(jq -r '.spec.matchingPrecedence' /tmp/fs.json)"
  has="$(jq -r '[.spec.rules[]?.subjects[]? | select(.kind=="ServiceAccount" and .serviceAccount.name=="report-exporter" and .serviceAccount.namespace=="starfleet")] | length' /tmp/fs.json)"
  if [ "$lvl" != "exporter-limited" ]; then echo "FAIL: priority level is '$lvl', expected exporter-limited"; fail=1; fi
  if [ "$has" -lt 1 ]; then echo "FAIL: no rule matches the service account report-exporter in starfleet"; fail=1; fi
  if [ "$prec" -lt 1000 ] || [ "$prec" -gt 9000 ]; then echo "FAIL: matchingPrecedence is $prec, expected 1000 to 9000"; fail=1; fi
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: report-exporter has its own limited pool"
fi
exit "$fail"
