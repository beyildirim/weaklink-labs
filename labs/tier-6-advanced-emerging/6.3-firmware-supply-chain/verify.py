from __future__ import annotations

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    _ = context
    checks = (
        ('Firmware signature verification is implemented', "test -f /app/verify_firmware.sh && grep -q 'openssl\\|gpg\\|cosign\\|sha256' /app/verify_firmware.sh"),
        ('Tampered firmware image fails signature verification', "/app/verify_firmware.sh /app/firmware/tampered_update.bin 2>&1 | grep -qi 'fail\\|invalid\\|reject'"),
        ('Legitimate firmware image passes signature verification', "/app/verify_firmware.sh /app/firmware/legitimate_update.bin 2>&1 | grep -qi 'pass\\|valid\\|ok\\|success'"),
        ('Firmware SBOM exists in CycloneDX or SPDX format', "find /app/firmware -name '*sbom*' -o -name '*spdx*' -o -name '*cyclonedx*' | grep -q '.'"),

    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
