from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Provenance attestation file exists', "test -f /app/provenance.json && grep -q 'predicateType\\|predicate' /app/provenance.json"),
        ('Attestation uses SLSA provenance predicate type', "test -f /app/provenance.json && grep -q 'slsa\\|https://slsa.dev' /app/provenance.json"),
        ('Image has an attached attestation', "cosign verify-attestation --allow-http-registry --allow-insecure-registry --key /app/cosign.pub --type slsaprovenance registry:5000/weaklink-app:attested 2>/dev/null | grep -q 'payloadType\\|predicateType'"),
        ('Verification of unattested image fails', '! cosign verify-attestation --allow-http-registry --allow-insecure-registry --key /app/cosign.pub --type slsaprovenance registry:5000/weaklink-app:no-provenance 2>/dev/null'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
