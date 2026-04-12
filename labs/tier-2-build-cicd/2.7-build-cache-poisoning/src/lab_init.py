from __future__ import annotations

import os
import subprocess

from weaklink_platform.gitea_seed import reset_gitea_repo, seed_git_repo_from_source
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


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
    cache_dir.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["pip", "download", "flask==3.0.0", "requests==2.31.0", "-d", str(cache_dir)],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    from pathlib import Path

    raise SystemExit(main_init(run))
