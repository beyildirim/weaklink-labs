from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Attacker key pair exists', 'test -f /app/attacker-cosign.key && test -f /app/attacker-cosign.pub'),
        ('Enforcement policy pins the trusted public key', "test -f /app/enforce-policy.yaml && grep -q 'cosign.pub\\|trusted' /app/enforce-policy.yaml"),
        ('Attacker-signed image fails trusted key verification', '! cosign verify --allow-http-registry --allow-insecure-registry --key /app/cosign.pub registry:5000/weaklink-app:attacker-signed 2>/dev/null'),
        ('Rollback attack is documented', "test -f /app/bypass-report.md && grep -qi 'rollback\\|replay\\|old.*signature' /app/bypass-report.md"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
