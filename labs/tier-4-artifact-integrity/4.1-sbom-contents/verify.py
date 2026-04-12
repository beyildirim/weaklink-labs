from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('SPDX format SBOM exists', "test -f /app/sbom-spdx.json && grep -q 'spdxVersion' /app/sbom-spdx.json"),
        ('CycloneDX format SBOM exists', "test -f /app/sbom-cdx.json && grep -q 'bomFormat' /app/sbom-cdx.json"),
        ('cdxgen SBOM exists', "test -f /app/sbom-cdxgen.json && grep -q 'bomFormat\\|components' /app/sbom-cdxgen.json"),
        ('Enriched SBOM includes vendored component (libcurl)', "test -f /app/sbom-enriched.json && grep -qi 'libcurl\\|vendored\\|manual' /app/sbom-enriched.json"),
        ('SBOM gaps documented (gaps.txt or gaps.md exists)', 'test -f /app/gaps.txt || test -f /app/gaps.md'),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
