from __future__ import annotations

from weaklink_platform.gitea_seed import create_gitea_user, reset_gitea_repo, seed_git_repo_from_source
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init
from weaklink_platform.runner_seed import create_simulated_runner


def run(context: InitContext) -> InitResult:
    repo_name = "wl-webapp"
    reset_gitea_repo(repo_name, delete_existing=True)
    seed_git_repo_from_source(
        source_dir=context.lab_root / "repo",
        repo_dir=context.repos_root / repo_name,
        repo_name=repo_name,
        commit_message="Initial commit: webapp with self-hosted runner CI",
        force_push=True,
    )
    create_gitea_user("attacker", "password", "attacker@evil.com")
    create_simulated_runner()
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
