from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Cosign key pair was generated', 'test -f /app/cosign.key && test -f /app/cosign.pub'),
        ('Image has been signed (cosign verify succeeds)', "cosign verify --allow-http-registry --allow-insecure-registry --key /app/cosign.pub registry:5000/weaklink-app:signed 2>/dev/null | grep -q 'Verified OK\\|payloadType'"),
        ('Verification policy file exists', 'test -f /app/policy.yaml || test -f /app/policy.yml || test -f /app/admission-policy.yaml'),
        ('Unsigned image fails verification', '! cosign verify --allow-http-registry --allow-insecure-registry --key /app/cosign.pub registry:5000/weaklink-app:unsigned 2>/dev/null'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
