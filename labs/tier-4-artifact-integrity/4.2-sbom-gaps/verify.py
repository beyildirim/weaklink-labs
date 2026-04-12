from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('SBOM from syft exists', "test -f /app/sbom-syft.json && (grep -q 'spdxVersion\\|bomFormat' /app/sbom-syft.json)"),
        ('SBOM from trivy exists', "test -f /app/sbom-trivy.json && (grep -q 'spdxVersion\\|bomFormat' /app/sbom-trivy.json)"),
        ('SBOM from cdxgen exists', "test -f /app/sbom-cdxgen.json && (grep -q 'spdxVersion\\|bomFormat' /app/sbom-cdxgen.json)"),
        ('Vulnerability scan output exists (grype or trivy)', 'test -f /app/vuln-scan.txt || test -f /app/vuln-scan.json'),
        ('Gap analysis documents the missed vendored CVE', "test -f /app/gap-analysis.md && grep -qi 'CVE\\|vendored\\|missed\\|gap' /app/gap-analysis.md"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
