# Question

Solve this question on: `terminal`

In `starfleet`, every pod accepts traffic from every other pod. Restrict it so that only one path stays open.

1. Add a default-deny ingress policy for all pods in `starfleet`.
2. Allow the pods labelled `app=shuttle` to reach the pods labelled `app=scout` on the pod port 9898.
3. No other client may reach `scout`, and `probe` must accept no traffic from `shuttle`.

The cluster enforces NetworkPolicy. `kubectl` already points at the cluster as the cluster administrator.
