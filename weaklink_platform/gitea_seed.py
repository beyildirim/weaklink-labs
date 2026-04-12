from __future__ import annotations

import base64
import json
import shutil
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from weaklink_platform.subprocess_utils import run


GITEA_URL = "http://gitea:3000"
GITEA_USER = "weaklink"
GITEA_PASS = "weaklink"


def _auth_header(username: str = GITEA_USER, password: str = GITEA_PASS) -> dict[str, str]:
    token = base64.b64encode(f"{username}:{password}".encode()).decode()
    return {"Authorization": f"Basic {token}"}


def _request_json(
    method: str,
    path: str,
    payload: dict[str, object] | None = None,
    *,
    ok_statuses: tuple[int, ...] = (200, 201, 202, 204, 409, 422),
) -> tuple[int, dict[str, object]]:
    headers = {"Content-Type": "application/json"}
    headers.update(_auth_header())
    data = json.dumps(payload).encode() if payload is not None else None
    request = Request(f"{GITEA_URL}{path}", data=data, method=method, headers=headers)
    try:
        with urlopen(request, timeout=15) as response:
            body = response.read().decode()
            return response.status, json.loads(body) if body else {}
    except HTTPError as exc:
        body = exc.read().decode()
        if exc.code in ok_statuses:
            return exc.code, json.loads(body) if body else {}
        raise


def gitea_repo_url(repo_name: str, *, owner: str = GITEA_USER) -> str:
    return f"{GITEA_URL}/{owner}/{repo_name}.git"


def reset_gitea_repo(
    repo_name: str,
    *,
    delete_existing: bool = False,
    auto_init: bool = False,
    default_branch: str = "main",
) -> None:
    if delete_existing:
        _request_json("DELETE", f"/api/v1/repos/{GITEA_USER}/{repo_name}", ok_statuses=(204, 404))
    payload = {"name": repo_name, "auto_init": auto_init, "default_branch": default_branch}
    _request_json("POST", "/api/v1/user/repos", payload=payload)


def create_gitea_user(
    username: str,
    password: str,
    email: str,
    *,
    must_change_password: bool = False,
) -> None:
    payload = {
        "username": username,
        "password": password,
        "email": email,
        "must_change_password": must_change_password,
    }
    _request_json("POST", "/api/v1/admin/users", payload=payload)


def set_repo_secret(repo_name: str, secret_name: str, value: str, *, owner: str = GITEA_USER) -> None:
    payload = {"data": value}
    _request_json("PUT", f"/api/v1/repos/{owner}/{repo_name}/actions/secrets/{secret_name}", payload=payload)


def init_git_repo(
    repo_dir: Path,
    *,
    branch: str = "main",
    user_name: str = "Hacker",
    user_email: str = "hacker@weaklink.local",
) -> None:
    run(["git", "init"], cwd=repo_dir)
    run(["git", "config", "user.name", user_name], cwd=repo_dir)
    run(["git", "config", "user.email", user_email], cwd=repo_dir)
    run(["git", "checkout", "-B", branch], cwd=repo_dir)


def commit_all(repo_dir: Path, subject: str, *, body: str | None = None) -> None:
    run(["git", "add", "-A"], cwd=repo_dir)
    command = ["git", "commit", "-m", subject]
    if body:
        command.extend(["-m", body])
    run(command, cwd=repo_dir)


def checkout_git_branch(repo_dir: Path, branch: str, *, create: bool = False) -> None:
    command = ["git", "checkout"]
    if create:
        command.append("-b")
    command.append(branch)
    run(command, cwd=repo_dir)


def push_git_branch(
    repo_dir: Path,
    repo_name: str,
    branch: str,
    *,
    set_upstream: bool = False,
) -> None:
    remote = gitea_repo_url(repo_name)
    run(["git", "remote", "remove", "origin"], cwd=repo_dir, check=False)
    run(["git", "remote", "add", "origin", remote], cwd=repo_dir)
    command = ["git", "push"]
    if set_upstream:
        command.append("-u")
    command.extend(["origin", branch])
    run(command, cwd=repo_dir)


def replace_dir_contents(destination: Path, source: Path) -> None:
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir(parents=True, exist_ok=True)
    for child in source.iterdir():
        target = destination / child.name
        if child.is_dir():
            shutil.copytree(child, target, dirs_exist_ok=True)
        else:
            shutil.copy2(child, target)


def seed_git_repo_from_source(
    *,
    source_dir: Path,
    repo_dir: Path,
    repo_name: str,
    commit_message: str,
    branch: str = "main",
    force_push: bool = False,
) -> None:
    replace_dir_contents(repo_dir, source_dir)
    git_dir = repo_dir / ".git"
    if git_dir.exists():
        shutil.rmtree(git_dir)

    init_git_repo(repo_dir, branch=branch)
    commit_all(repo_dir, commit_message)
    run(["git", "remote", "remove", "origin"], cwd=repo_dir, check=False)
    run(["git", "remote", "add", "origin", gitea_repo_url(repo_name)], cwd=repo_dir)

    push_command = ["git", "push", "-u"]
    if force_push:
        push_command.append("-f")
    push_command.extend(["origin", branch])
    run(push_command, cwd=repo_dir)
