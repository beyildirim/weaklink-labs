from __future__ import annotations

from weaklink_platform.gitea_seed import (
    create_gitea_user,
    reset_gitea_repo,
    seed_git_repo_from_source,
    set_repo_secret,
)
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    repo_name = "wl-webapp"
    reset_gitea_repo(repo_name, delete_existing=True)
    seed_git_repo_from_source(
        source_dir=context.lab_root / "repo",
        repo_dir=context.repos_root / repo_name,
        repo_name=repo_name,
        commit_message="Initial commit: webapp with CI pipeline",
    )
    set_repo_secret(repo_name, "DEPLOY_TOKEN", "ghp_deploy_x8k2m5n7p9q1r3t6v0w4y")
    create_gitea_user("attacker", "password", "attacker@evil.com")
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
