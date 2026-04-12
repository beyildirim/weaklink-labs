from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Malicious post-install hook removed from chart', "! grep -r 'cluster-admin' /app/metrics-aggregator/templates/"),
        ('No ClusterRoleBinding granting cluster-admin to default SA', "! helm template /app/metrics-aggregator/ 2>/dev/null | grep -A5 'ClusterRoleBinding' | grep -q 'cluster-admin'"),
        ('Hook validation policy exists', 'test -f /app/policies/restrict-hooks.yaml || test -f /app/policies/restrict-clusterrolebinding.yaml'),
        ('User has reviewed rendered manifests (review marker exists)', 'test -f /app/.helm-reviewed'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
