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
sc="$(kubectl get deployment shuttle -n starfleet -o json | jq -c '.spec.template.spec.containers[0].securityContext // {}')"
chk() { echo "$sc" | jq -e "$1" >/dev/null 2>&1 || { echo "FAIL: shuttle in starfleet: $2"; fail=1; }; }
chk '.runAsNonRoot==true' "runAsNonRoot is not true"
chk '(.runAsUser // 0) > 0' "runAsUser is not a non-zero number"
chk '.allowPrivilegeEscalation==false' "allowPrivilegeEscalation is not false"
chk '.readOnlyRootFilesystem==true' "readOnlyRootFilesystem is not true"
chk '(.capabilities.drop // []) | index("ALL") != null' "capabilities.drop does not contain ALL"
if [ "$fail" -eq 0 ]; then
  echo "PASS: the securityContext of shuttle is set"
fi
exit "$fail"
