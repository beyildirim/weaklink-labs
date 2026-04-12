from __future__ import annotations

from pathlib import Path

from weaklink_platform.lab_runtime import (
    VerificationContext,
    fail_check,
    http_ok,
    main_verify,
    pass_check,
    result_from_checks,
    run_command,
)


def run(context: VerificationContext):
    checks = []
    checks.append(
        pass_check("Local PyPI server is running")
        if http_ok("http://pypi-private:8080/simple/")
        else fail_check("Local PyPI server is running")
    )
    checks.append(
        pass_check("/tmp/pwned does not exist (malicious setup.py did not execute)")
        if not (Path("/tmp/pwned")).exists()
        else fail_check("/tmp/pwned does not exist (malicious setup.py did not execute)")
    )
    requirements = context.workspace_root / "requirements.txt"
    checks.append(
        pass_check("Requirements file with --hash= entries exists")
        if requirements.exists() and "--hash=" in requirements.read_text()
        else fail_check("Requirements file with --hash= entries exists")
    )
    checks.append(
        pass_check("safe-utils package is installed")
        if run_command(["pip", "show", "safe-utils"]).returncode == 0
        else fail_check("safe-utils package is installed")
    )
    checks.append(
        pass_check("malicious-utils package is not installed")
        if run_command(["pip", "show", "malicious-utils"]).returncode != 0
        else fail_check("malicious-utils package is not installed")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
