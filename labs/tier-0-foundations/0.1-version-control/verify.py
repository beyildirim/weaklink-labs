from __future__ import annotations

from weaklink_platform.lab_runtime import (
    VerificationContext,
    fail_check,
    http_get_json,
    http_ok,
    main_verify,
    pass_check,
    result_from_checks,
    run_command,
)


GITEA_URL = "http://gitea:3000"
AUTH = ("weaklink", "weaklink")
REPO = "weaklink/web-app"


def _as_int(value: object) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return 0


def run(context: VerificationContext):
    checks = []
    gitea_ready = http_ok(f"{GITEA_URL}/api/v1/version")
    checks.append(
        pass_check("Gitea server is running")
        if gitea_ready
        else fail_check(f"Gitea server is not reachable at {GITEA_URL}")
    )

    rules: list[dict[str, object]] = []
    pulls: list[object] = []
    if gitea_ready:
        try:
            protections = http_get_json(f"{GITEA_URL}/api/v1/repos/{REPO}/branch_protections", auth=AUTH)
            if isinstance(protections, list):
                rules = [item for item in protections if isinstance(item, dict)]
        except Exception:
            rules = []
        try:
            payload = http_get_json(f"{GITEA_URL}/api/v1/repos/{REPO}/pulls?state=all", auth=AUTH)
            if isinstance(payload, list):
                pulls = payload
        except Exception:
            pulls = []

    main_rules = [
        rule
        for rule in rules
        if str(rule.get("branch_name") or rule.get("rule_name") or "").strip() == "main"
    ]
    checks.append(
        pass_check("Branch protection rule exists for 'main'")
        if main_rules
        else fail_check("Branch protection rule exists for 'main'")
    )
    push_blocked = any(
        rule.get("enable_push") is False or _as_int(rule.get("required_approvals")) > 0
        for rule in main_rules
    )
    checks.append(
        pass_check("Direct push is blocked or reviews are required")
        if push_blocked
        else fail_check("Direct push is blocked or reviews are required")
    )
    checks.append(
        pass_check("At least one pull request exists (not a direct push)")
        if pulls
        else fail_check("At least one pull request exists (not a direct push)")
    )

    local_repo = context.workspace_root / "web-app"
    if not (local_repo / ".git").exists():
        checks.append(
            fail_check(f"Local repository clone missing at {local_repo}. Complete the clone step first.")
        )
    else:
        run_command(["git", "-C", str(local_repo), "pull", "-q"])
        build_script = local_repo / "build.sh"
        contents = build_script.read_text() if build_script.exists() else ""
        clean = "EXFILTRATED" not in contents and "stolen-secrets" not in contents
        checks.append(
            pass_check("Malicious code has been reverted from build.sh")
            if clean
            else fail_check("Malicious code has been reverted from build.sh")
        )

    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
