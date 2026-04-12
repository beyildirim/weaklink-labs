from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Backdoor detection script identifies obfuscated test files', "test -f /app/detect_xz_backdoor.sh && bash /app/detect_xz_backdoor.sh /app 2>&1 | grep -qi 'suspicious\\|backdoor\\|detected'"),
        ('Build reproducibility verification script exists', "test -f /app/check_reproducible.sh && grep -q 'diff\\|sha256\\|compare' /app/check_reproducible.sh"),
        ('Analysis covers social engineering timeline', "test -f /app/analysis.md && grep -qi 'jia.*tan\\|social.engineer\\|maintainer.*burnout' /app/analysis.md"),
        ('Analysis covers build system injection via M4 macros', "test -f /app/analysis.md && grep -qi 'm4\\|build.*script\\|configure\\|ifunc\\|liblzma' /app/analysis.md"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
