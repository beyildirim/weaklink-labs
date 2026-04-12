from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Chart.yaml dependencies use exact version pins (no ranges)', "grep -E 'version:' /app/webapp/Chart.yaml | grep -v -E '[\\^~>]'"),
        ('Chart.lock exists with integrity digests', "test -f /app/webapp/Chart.lock && grep -q 'digest:' /app/webapp/Chart.lock"),
        ('Untrusted public Helm repo is not configured', "! helm repo list 2>/dev/null | grep -q 'untrusted-public'"),
        ('Private Helm repo is configured', "helm repo list 2>/dev/null | grep -q 'private-charts'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
