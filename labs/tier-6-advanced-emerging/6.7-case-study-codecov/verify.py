from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('CI config does not pipe external scripts into bash', "! grep -rq 'curl.*|.*bash\\|curl.*|.*sh\\|wget.*|.*bash' /app/.github/workflows/"),
        ('Script integrity verification checks SHA-256 before execution', "test -f /app/verify_script.sh && grep -q 'sha256\\|checksum\\|hash' /app/verify_script.sh"),
        ('CI uses official Codecov action (pinned by SHA) instead of bash script', "test -f /app/.github/workflows/ci-fixed.yml && grep -q 'codecov/codecov-action@' /app/.github/workflows/ci-fixed.yml"),
        ('Analysis covers Codecov exfiltration mechanism', "test -f /app/analysis.md && grep -qi 'exfiltrat\\|environment.*variable\\|curl.*bash\\|codecov' /app/analysis.md"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
