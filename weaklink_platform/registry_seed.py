from __future__ import annotations

import json
import os
import secrets
import shutil
import subprocess
import tempfile
import time
import uuid
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen


VERDACCIO_URL = "http://verdaccio:4873"


def wait_for_http(url: str, *, attempts: int = 60, delay: float = 1.0) -> None:
    for _ in range(attempts):
        try:
            with urlopen(url, timeout=3):
                return
        except OSError:
            time.sleep(delay)
    raise RuntimeError(f"Service did not become ready at {url}")


def _request_json(
    method: str,
    url: str,
    payload: dict[str, object],
    *,
    headers: dict[str, str] | None = None,
    ok_statuses: tuple[int, ...] = (200, 201, 202, 204, 409, 422),
) -> dict[str, object]:
    merged_headers = {"Content-Type": "application/json"}
    if headers:
        merged_headers.update(headers)
    request = Request(url, data=json.dumps(payload).encode(), method=method, headers=merged_headers)
    try:
        with urlopen(request, timeout=15) as response:
            body = response.read().decode()
            return json.loads(body) if body else {}
    except HTTPError as exc:
        body = exc.read().decode()
        if exc.code not in ok_statuses:
            raise
        return json.loads(body) if body else {}


def verdaccio_token(
    registry_url: str = VERDACCIO_URL,
    *,
    username: str | None = None,
    password: str | None = None,
) -> str:
    username = username or f"labuser-{uuid.uuid4().hex[:8]}"
    password = password or secrets.token_urlsafe(18)
    payload = {"name": username, "password": password}
    response = _request_json("PUT", f"{registry_url}/-/user/org.couchdb.user:{username}", payload)
    token = str(response.get("token", ""))
    if token:
        return token
    response = _request_json("PUT", f"{registry_url}/-/user/org.couchdb.user:{username}", payload)
    token = str(response.get("token", ""))
    if not token:
        raise RuntimeError(f"Failed to obtain Verdaccio auth token for {registry_url}")
    return token


def write_npmrc(
    token: str,
    *,
    registry_url: str = VERDACCIO_URL,
    npmrc_path: Path | None = None,
) -> Path:
    npmrc = npmrc_path or (Path.home() / ".npmrc")
    registry_host = registry_url.removeprefix("http://").removeprefix("https://").rstrip("/")
    npmrc.write_text(f"//{registry_host}/:_authToken={token}\nregistry={registry_url}/\n")
    return npmrc


def prepare_verdaccio(
    *,
    registry_url: str = VERDACCIO_URL,
    npmrc_path: Path | None = None,
) -> str:
    wait_for_http(f"{registry_url}/-/ping")
    token = verdaccio_token(registry_url)
    write_npmrc(token, registry_url=registry_url, npmrc_path=npmrc_path)
    return token


def npm_publish(package_dir: Path, *, registry_url: str = VERDACCIO_URL) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["npm", "publish", "--registry", registry_url],
        cwd=str(package_dir),
        text=True,
        capture_output=True,
        check=False,
    )


def npm_unpublish(package_spec: str, *, registry_url: str = VERDACCIO_URL) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["npm", "unpublish", package_spec, "--force", "--registry", registry_url],
        text=True,
        capture_output=True,
        check=False,
    )


def publish_inline_package(
    package_manifest: dict[str, object],
    files: dict[str, str],
    *,
    registry_url: str = VERDACCIO_URL,
) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as temp_dir:
        package_dir = Path(temp_dir)
        (package_dir / "package.json").write_text(json.dumps(package_manifest, indent=2) + "\n")
        for relative_path, content in files.items():
            target = package_dir / relative_path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
        return npm_publish(package_dir, registry_url=registry_url)


def reset_path(path: Path) -> None:
    if path.exists():
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()
    path.mkdir(parents=True, exist_ok=True)


def populate_pip_download_cache(cache_dir: Path, packages: list[str]) -> None:
    cache_dir.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["pip", "download", *packages, "-d", str(cache_dir)],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        env=os.environ.copy(),
    )
