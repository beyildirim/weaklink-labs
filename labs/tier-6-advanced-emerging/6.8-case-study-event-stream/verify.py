from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Package lockfile exists and contains integrity hashes', "test -f /app/package-lock.json && grep -q 'integrity' /app/package-lock.json"),
        ('Maintainer change monitoring script exists', "test -f /app/monitor_maintainers.sh && grep -q 'npm\\|maintainer\\|owner' /app/monitor_maintainers.sh"),
        ('npm audit check is configured in CI', "grep -rq 'npm audit\\|audit-ci\\|better-npm-audit' /app/.github/workflows/ 2>/dev/null || grep -q 'npm audit' /app/check_deps.sh 2>/dev/null"),
        ('Analysis covers both event-stream and ua-parser-js incidents', "test -f /app/analysis.md && grep -qi 'event-stream' /app/analysis.md && grep -qi 'ua-parser' /app/analysis.md"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
