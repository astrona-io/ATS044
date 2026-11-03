# Question

Solve this question on: `terminal`

`radar` in `starfleet` is not reachable, and the namespace accepts traffic from every pod. Repair the service and then restrict the namespace.

1. Repair the Service `radar` so that it has ready endpoints and forwards to the container port. Keep the Service port at 80.
2. Add a default-deny ingress policy for all pods in `starfleet`.
3. Allow the pods labelled `app=shuttle` to reach `radar` and `scout` on the pod port 9898.
4. The pods in `outpost` must reach neither of them.

The cluster enforces NetworkPolicy. `kubectl` already points at the cluster as the cluster administrator.
