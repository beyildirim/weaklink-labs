from __future__ import annotations

from weaklink_platform.lab_runtime import (
    VerificationContext,
    fail_check,
    http_get,
    http_get_json,
    http_ok,
    main_verify,
    pass_check,
    result_from_checks,
)


GITEA_URL = "http://gitea:3000"
AUTH = ("weaklink", "weaklink")
REPO = "weaklink/ci-demo"


def run(context: VerificationContext):
    _ = context
    checks = []
    gitea_ready = http_ok(f"{GITEA_URL}/api/v1/version")
    checks.append(
        pass_check("Gitea server is running")
        if gitea_ready
        else fail_check("Gitea server is running")
    )
    workflow_ok = False
    main_protected = False
    has_prs = False
    exfil_removed = False
    if gitea_ready:
        try:
            workflow = http_get_json(
                f"{GITEA_URL}/api/v1/repos/{REPO}/contents/.gitea/workflows/ci.yml",
                auth=AUTH,
            )
            workflow_ok = bool(workflow)
        except Exception:
            workflow_ok = False
        try:
            protections = http_get_json(f"{GITEA_URL}/api/v1/repos/{REPO}/branch_protections", auth=AUTH)
            if isinstance(protections, list):
                main_protected = any(
                    "main" == str(item.get("branch_name") or item.get("rule_name") or "").strip()
                    for item in protections
                    if isinstance(item, dict)
                )
        except Exception:
            main_protected = False
        try:
            pulls = http_get_json(f"{GITEA_URL}/api/v1/repos/{REPO}/pulls?state=all", auth=AUTH)
            has_prs = isinstance(pulls, list) and len(pulls) > 0
        except Exception:
            has_prs = False
        try:
            workflow_raw = http_get(
                f"{GITEA_URL}/api/v1/repos/{REPO}/raw/.gitea/workflows/ci.yml?ref=main",
                auth=AUTH,
            )
            exfil_removed = "EXFILTRATED DEPLOY_KEY=" not in workflow_raw
        except Exception:
            exfil_removed = False

    checks.append(
        pass_check("CI workflow file exists in repository")
        if workflow_ok
        else fail_check("CI workflow file exists in repository")
    )
    checks.append(
        pass_check("Branch protection enabled on main")
        if main_protected
        else fail_check("Branch protection enabled on main")
    )
    checks.append(
        pass_check("At least one pull request exists for ci-demo")
        if has_prs
        else fail_check("At least one pull request exists for ci-demo")
    )
    checks.append(
        pass_check("Exfiltration step has been removed from main")
        if exfil_removed
        else fail_check("Exfiltration step has been removed from main")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
