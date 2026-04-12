from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('No stage-1 compromise marker (/tmp/stage1-typosquat does not exist)', 'test ! -f /tmp/stage1-typosquat'),
        ('No stage-2 compromise marker (/tmp/stage2-ci-poison does not exist)', 'test ! -f /tmp/stage2-ci-poison'),
        ('No stage-3 compromise marker (/tmp/stage3-image-backdoor does not exist)', 'test ! -f /tmp/stage3-image-backdoor'),
        ('Package lockfile contains integrity hashes', "grep -q 'integrity\\|sha512\\|sha256' /app/package-lock.json 2>/dev/null || grep -q 'hash\\|sha256' /app/requirements.txt 2>/dev/null"),
        ('CI configuration is protected (CODEOWNERS or branch protection)', "test -f /app/.github/CODEOWNERS && grep -q 'workflows' /app/.github/CODEOWNERS"),
        ('Container image signature verification is configured', "test -f /app/verify_image.sh && grep -q 'cosign\\|notation\\|digest' /app/verify_image.sh"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
