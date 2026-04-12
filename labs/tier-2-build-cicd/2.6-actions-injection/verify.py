from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    repo = context.repos_root / "wl-webapp"
    issue_wf = quote(str(repo / ".gitea" / "workflows" / "issue-handler.yml"))
    pr_wf = quote(str(repo / ".gitea" / "workflows" / "pr-handler.yml"))
    checks = [
        (
            "No direct expression interpolation in run: blocks for issue title",
            f"! grep -E 'run:.*\\$\\{{\\{{.*issue\\.title' {issue_wf} && ! grep -B 0 'echo.*\\$\\{{\\{{.*issue\\.' {issue_wf}",
        ),
        ("Issue title passed through env variable", f"grep -q 'ISSUE_TITLE:.*github.event.issue.title' {issue_wf}"),
        ("Issue body passed through env variable", f"grep -q 'ISSUE_BODY:.*github.event.issue.body' {issue_wf}"),
        ("Run blocks use shell variables not expressions", f"grep -A 1 'run:' {issue_wf} | grep -q 'ISSUE_TITLE}}\\|ISSUE_BODY}}\\|ISSUE_AUTHOR}}'"),
        ("Slack notification uses safe JSON encoding", f"grep -q 'jq' {issue_wf}"),
    ]
    if (repo / ".gitea" / "workflows" / "pr-handler.yml").exists():
        checks.append(
            (
                "PR handler does not use direct expression interpolation",
                f"! grep -E '\\$\\{{\\{{.*comment\\.body' {pr_wf} | grep -v '^[[:space:]]*#' | grep -q 'run:'",
            )
        )
    return run_command_checks(tuple(checks))


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
