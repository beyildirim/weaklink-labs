from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Original (unmodified) SBOM exists', "test -f /app/sbom-original.json && grep -q 'bomFormat\\|spdxVersion' /app/sbom-original.json"),
        ('Tampered SBOM exists (vulnerable component removed)', 'test -f /app/sbom-tampered.json'),
        ('SBOM was signed (signature file exists)', 'test -f /app/sbom-original.json.sig || test -f /app/sbom-signed.json.sig'),
        ('Tampered SBOM fails signature verification', '! cosign verify-blob --key /app/cosign.pub --signature /app/sbom-original.json.sig /app/sbom-tampered.json 2>/dev/null'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
