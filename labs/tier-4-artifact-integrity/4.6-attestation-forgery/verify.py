from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Forged attestation file exists', "test -f /app/forged-attestation.json && grep -q 'predicateType' /app/forged-attestation.json"),
        ('Forged attestation claims trusted CI builder identity', "test -f /app/forged-attestation.json && grep -q 'github.com\\|ci-builder\\|trusted' /app/forged-attestation.json"),
        ('Forgery verification documented (attack-log.md)', "test -f /app/attack-log.md && grep -qi 'verified\\|pass\\|forgery\\|succeeded' /app/attack-log.md"),
        ('Defense policy checks builder identity (OIDC issuer or certificate identity)', "test -f /app/keyless-policy.yaml && grep -qi 'issuer\\|identity\\|oidc\\|certificate' /app/keyless-policy.yaml"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
