from __future__ import annotations

from pathlib import Path

from weaklink_platform.lab_runtime import VerificationContext, fail_check, main_verify, pass_check, result_from_checks, run_command


def _normalized_lines(path: Path) -> list[str]:
    return [
        line.strip()
        for line in path.read_text().splitlines()
        if line.strip() and not line.startswith("#")
    ]


def run(context: VerificationContext):
    _ = context
    checks = []
    project = context.app_root / "project"
    verify_script = project / "verify-lockfile.sh"
    checks.append(
        pass_check("Compromise marker /tmp/lockfile-pwned does NOT exist")
        if not Path("/tmp/lockfile-pwned").exists()
        else fail_check("Compromise marker /tmp/lockfile-pwned does NOT exist")
    )
    checks.append(
        pass_check("verify-lockfile.sh script exists")
        if verify_script.exists()
        else fail_check("verify-lockfile.sh script exists")
    )
    checks.append(
        pass_check("verify-lockfile.sh is executable")
        if verify_script.exists() and verify_script.stat().st_mode & 0o111
        else fail_check("verify-lockfile.sh is executable")
    )
    fresh_lockfile = Path("/tmp/fresh-lockfile.txt")
    result = run_command(
        [
            "pip-compile",
            "--generate-hashes",
            "--index-url",
            "http://pypi-private:8080/simple/",
            "--trusted-host",
            "pypi-private",
            "--quiet",
            "requirements.in",
            "--output-file",
            str(fresh_lockfile),
        ],
        cwd=project,
    )
    lock_ok = False
    target_lockfile = project / "requirements.txt"
    if result.returncode == 0 and target_lockfile.exists() and fresh_lockfile.exists():
        lock_ok = _normalized_lines(target_lockfile) == _normalized_lines(fresh_lockfile)
    checks.append(
        pass_check("Lockfile matches fresh pip-compile output (not tampered)")
        if lock_ok
        else fail_check("Lockfile matches fresh pip-compile output (not tampered)")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
