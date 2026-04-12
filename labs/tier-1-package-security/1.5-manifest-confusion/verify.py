from __future__ import annotations

from pathlib import Path

from weaklink_platform.lab_runtime import VerificationContext, fail_check, main_verify, pass_check, result_from_checks


def run(context: VerificationContext):
    workspace = context.app_root
    checks = []
    checks.append(
        pass_check("No compromise marker (/tmp/manifest-confusion-pwned)")
        if not Path("/tmp/manifest-confusion-pwned").exists()
        else fail_check("No compromise marker (/tmp/manifest-confusion-pwned)")
    )
    checks.append(
        pass_check("evil-pkg not in node_modules")
        if not (workspace / "node_modules" / "evil-pkg").exists()
        else fail_check("evil-pkg not in node_modules")
    )
    lockfile = workspace / "package-lock.json"
    checks.append(
        pass_check("package-lock.json exists with integrity hashes")
        if lockfile.exists() and '"integrity"' in lockfile.read_text()
        else fail_check("package-lock.json exists with integrity hashes")
    )
    compare_script = workspace / "compare-manifests.sh"
    check_script = workspace / "check-manifest.sh"
    available = any(path.exists() and path.stat().st_mode & 0o111 for path in (compare_script, check_script))
    checks.append(
        pass_check("Manifest comparison tool available")
        if available
        else fail_check("Manifest comparison tool available")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
