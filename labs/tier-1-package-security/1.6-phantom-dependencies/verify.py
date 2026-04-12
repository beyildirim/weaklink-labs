from __future__ import annotations

import json
import subprocess

from weaklink_platform.lab_runtime import VerificationContext, fail_check, main_verify, pass_check, result_from_checks


def run(context: VerificationContext):
    workspace = context.app_root
    checks = []
    package_json = workspace / "package.json"
    package_data: dict[str, object] = {}
    if package_json.exists():
        package_data = json.loads(package_json.read_text())
    dependencies = package_data.get("dependencies", {}) if isinstance(package_data, dict) else {}
    debug_version = dependencies.get("debug") if isinstance(dependencies, dict) else None
    checks.append(
        pass_check("No phantom dependencies (debug in package.json)")
        if debug_version is not None
        else fail_check("No phantom dependencies (debug in package.json)")
    )
    safe_debug = isinstance(debug_version, str) and "99" not in debug_version
    checks.append(
        pass_check("debug version is safe (not malicious 99.x)")
        if safe_debug
        else fail_check("debug version is safe (not malicious 99.x)")
    )
    app_js = workspace / "app.js"
    app_ok = False
    if app_js.exists():
        completed = subprocess.run(
            ["node", "app.js"],
            cwd=str(workspace),
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        output = f"{completed.stdout}\n{completed.stderr}".lower()
        app_ok = "cannot find module" not in output and "error" not in output
    checks.append(
        pass_check("App starts successfully")
        if app_ok
        else fail_check("App starts successfully")
    )
    checks.append(
        pass_check("package-lock.json exists")
        if (workspace / "package-lock.json").exists()
        else fail_check("package-lock.json exists")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
