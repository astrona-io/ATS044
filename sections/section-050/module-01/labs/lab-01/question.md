# Question

Solve this question on: `terminal`

The Deployment `radar` in `starfleet` is running, but `shuttle` cannot reach it through the Service `radar` on port 80.

1. Find the stage of the request path that fails. Check the endpoints and the port mapping.
2. Correct the Service so that `http://radar/healthz` answers from `shuttle`.
3. Keep the Service port at 80 and do not delete the Deployment.

`kubectl` already points at the cluster as the cluster administrator.
