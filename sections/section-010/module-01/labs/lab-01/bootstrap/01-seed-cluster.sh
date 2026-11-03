#!/usr/bin/env bash
# Starting state for this lab. Environment only: it creates the workloads and
# the faulty setup. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
if [ -f "$DIR/manifests/extra.yaml" ]; then
  kubectl apply -f "$DIR/manifests/extra.yaml"
fi
if [ -f "$DIR/bootstrap/02-extra.sh" ]; then
  bash "$DIR/bootstrap/02-extra.sh"
fi

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
