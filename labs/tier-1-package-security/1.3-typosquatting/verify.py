from __future__ import annotations

from pathlib import Path

from weaklink_platform.lab_runtime import (
    VerificationContext,
    fail_check,
    main_verify,
    pass_check,
    result_from_checks,
    run_command,
)


def run(context: VerificationContext):
    _ = context
    checks = []
    checks.append(
        pass_check("Typosquatted 'reqeusts' package is NOT installed")
        if run_command(["pip", "show", "reqeusts"]).returncode != 0
        else fail_check("Typosquatted 'reqeusts' package is NOT installed")
    )
    checks.append(
        pass_check("Legitimate 'requests' package IS installed")
        if run_command(["pip", "show", "requests"]).returncode == 0
        else fail_check("Legitimate 'requests' package IS installed")
    )
    checks.append(
        pass_check("Exfiltration file /tmp/typosquat-exfil does NOT exist")
        if not (Path("/tmp/typosquat-exfil")).exists()
        else fail_check("Exfiltration file /tmp/typosquat-exfil does NOT exist")
    )
    requirements = context.app_root / "requirements.txt"
    checks.append(
        pass_check("requirements.txt exists with pinned versions (==)")
        if requirements.exists() and "==" in requirements.read_text()
        else fail_check("requirements.txt exists with pinned versions (==)")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
