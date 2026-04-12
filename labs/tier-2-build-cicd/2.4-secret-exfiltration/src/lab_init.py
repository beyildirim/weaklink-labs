from __future__ import annotations

from weaklink_platform.gitea_seed import reset_gitea_repo, seed_git_repo_from_source, set_repo_secret
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    repo_name = "wl-webapp"
    reset_gitea_repo(repo_name, delete_existing=True)
    seed_git_repo_from_source(
        source_dir=context.lab_root / "repo",
        repo_dir=context.repos_root / repo_name,
        repo_name=repo_name,
        commit_message="Initial commit: webapp with overly-permissive CI secrets",
    )
    for secret in ("DEPLOY_TOKEN", "DB_PASSWORD", "API_KEY"):
        set_repo_secret(repo_name, secret, f"secret-{secret.lower()}-7f3a9b2c4d")
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
