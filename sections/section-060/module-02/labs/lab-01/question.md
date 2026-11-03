# Question

Solve this question on: `terminal`

The Deployment `probe` in `starfleet` reads the database password from the Secret `report-db` through the environment variable `DB_PASSWORD`. Anyone who can run a command in the container prints the password.

1. Remove the environment variable that takes its value from a Secret.
2. Mount the Secret `report-db` into the container `probe` as a read-only volume at `/etc/report-db`.
3. The Deployment must roll out and stay available. Do not delete the Secret.

`kubectl` already points at the cluster as the cluster administrator.
