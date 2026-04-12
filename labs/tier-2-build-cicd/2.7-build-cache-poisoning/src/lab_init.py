from __future__ import annotations

import os
from pathlib import Path

from weaklink_platform.gitea_seed import reset_gitea_repo, seed_git_repo_from_source
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init
from weaklink_platform.registry_seed import populate_pip_download_cache


def run(context: InitContext) -> InitResult:
    repo_name = "wl-webapp"
    reset_gitea_repo(repo_name, delete_existing=True)
    seed_git_repo_from_source(
        source_dir=context.lab_root / "repo",
        repo_dir=context.repos_root / repo_name,
        repo_name=repo_name,
        commit_message="Initial commit: webapp with cached CI pipeline",
        force_push=True,
    )
    cache_dir = Path(os.environ.get("HOME", "/home/hacker")) / ".cache" / "pip" / "wheels"
    populate_pip_download_cache(cache_dir, ["flask==3.0.0", "requests==2.31.0"])
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
