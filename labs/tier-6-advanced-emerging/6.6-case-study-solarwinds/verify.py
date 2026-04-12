from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Build tampering detection script identifies DLL injection', "test -f /app/detect_build_tampering.sh && bash /app/detect_build_tampering.sh /app/build-output 2>&1 | grep -qi 'tamper\\|inject\\|mismatch\\|suspicious'"),
        ('Reproducible build comparison script exists', "test -f /app/verify_build.sh && grep -q 'diff\\|sha256\\|reproducible\\|compare' /app/verify_build.sh"),
        ('Analysis covers Sunburst DLL injection mechanism', "test -f /app/analysis.md && grep -qi 'SolarWinds.Orion.Core.BusinessLayer\\|sunburst\\|dll' /app/analysis.md"),
        ('Analysis covers build system isolation and SLSA', "test -f /app/analysis.md && grep -qi 'isol\\|slsa\\|hermetic\\|reproducible' /app/analysis.md"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
