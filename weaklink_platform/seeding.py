from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import secrets
import shutil
import subprocess
import tarfile
import tempfile
import time
import uuid
from pathlib import Path
from json import JSONDecodeError
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from weaklink_platform.console import Style, info, ok, warn


LABS_ROOT = Path("/labs")
PYPI_PRIVATE_UPLOAD = "http://pypi-private:8080/"
PYPI_PUBLIC_UPLOAD = "http://pypi-public:8080/"
VERDACCIO_URL = "http://verdaccio:4873"
GITEA_URL = "http://gitea:3000"
GITEA_USER = "weaklink"
GITEA_PASS = "weaklink"
GITEA_EMAIL = "admin@weaklink.local"
REGISTRY_URL = "http://registry:5000"


def http_request(
    method: str,
    url: str,
    *,
    data: bytes | None = None,
    headers: dict[str, str] | None = None,
    ok_statuses: tuple[int, ...] = (200, 201, 202, 204, 409, 422),
    timeout: int = 10,
) -> tuple[int, bytes, dict[str, str]]:
    request = Request(url, data=data, method=method, headers=headers or {})
    try:
        with urlopen(request, timeout=timeout) as response:
            return response.status, response.read(), dict(response.headers.items())
    except HTTPError as exc:
        body = exc.read()
        if exc.code in ok_statuses:
            return exc.code, body, dict(exc.headers.items())
        raise


def request_json(
    method: str,
    url: str,
    payload: dict[str, object],
    *,
    headers: dict[str, str] | None = None,
    ok_statuses: tuple[int, ...] = (200, 201, 202, 204, 409, 422),
) -> tuple[int, dict[str, object], dict[str, str]]:
    merged_headers = {"Content-Type": "application/json"}
    if headers:
        merged_headers.update(headers)
    status, body, response_headers = http_request(
        method,
        url,
        data=json.dumps(payload).encode(),
        headers=merged_headers,
        ok_statuses=ok_statuses,
    )
    if not body:
        return status, {}, response_headers
    try:
        return status, json.loads(body.decode()), response_headers
    except JSONDecodeError:
        return status, {}, response_headers


def basic_auth_header(username: str, password: str) -> dict[str, str]:
    token = base64.b64encode(f"{username}:{password}".encode()).decode()
    return {"Authorization": f"Basic {token}"}


def gitea_git_auth_header() -> str:
    token = base64.b64encode(f"{GITEA_USER}:{GITEA_PASS}".encode()).decode()
    return f"Authorization: Basic {token}"


def wait_for_service(name: str, url: str, *, max_wait: int = 120) -> None:
    info(f"Waiting for {name} at {url}...")
    for _ in range(max_wait):
        try:
            with urlopen(url, timeout=2):
                ok(f"{name} is ready.")
                return
        except (OSError, HTTPError, URLError):
            time.sleep(1)
    raise RuntimeError(f"{name} did not become ready within {max_wait}s")


def _multipart_payload(fields: dict[str, str], file_field: tuple[str, str, bytes]) -> tuple[bytes, str]:
    boundary = f"weaklink-{uuid.uuid4().hex}"
    lines: list[bytes] = []
    for name, value in fields.items():
        lines.extend(
            [
                f"--{boundary}".encode(),
                f'Content-Disposition: form-data; name="{name}"'.encode(),
                b"",
                value.encode(),
            ]
        )
    field_name, filename, content = file_field
    lines.extend(
        [
            f"--{boundary}".encode(),
            f'Content-Disposition: form-data; name="{field_name}"; filename="{filename}"'.encode(),
            b"Content-Type: application/octet-stream",
            b"",
            content,
        ]
    )
    lines.append(f"--{boundary}--".encode())
    body = b"\r\n".join(lines) + b"\r\n"
    return body, f"multipart/form-data; boundary={boundary}"


def build_and_upload_pypi_package(package_dir: Path, registry_url: str) -> None:
    package_name = package_dir.name
    info(f"  Building {package_name}...")
    dist_dir = package_dir / "dist"
    shutil.rmtree(dist_dir, ignore_errors=True)
    subprocess.run(["python", "setup.py", "sdist", "-q"], cwd=package_dir, check=True)
    for dist_file in sorted(dist_dir.glob("*")):
        body, content_type = _multipart_payload(
            {":action": "file_upload"},
            ("content", dist_file.name, dist_file.read_bytes()),
        )
        try:
            http_request(
                "POST",
                registry_url,
                data=body,
                headers={"Content-Type": content_type},
                ok_statuses=(200, 201, 409),
            )
        except Exception:
            warn(f"  Failed to upload {dist_file.name} to {registry_url}")
    ok(f"  {package_name} uploaded")


def _copy_tree(source: Path, destination: Path) -> None:
    shutil.copytree(source, destination, dirs_exist_ok=True)


def seed_pypi_private() -> None:
    print(f"{Style.BOLD}--- Seeding PyPI Private ---{Style.NC}")
    packages = (
        LABS_ROOT / "tier-0-foundations/0.2-package-managers/src/packages/safe-utils",
        LABS_ROOT / "tier-1-package-security/1.1-dependency-resolution/src/packages/internal-utils-1.0.0",
        LABS_ROOT / "tier-1-package-security/1.1-dependency-resolution/src/packages/logging-helper-1.0.0",
        LABS_ROOT / "tier-1-package-security/1.1-dependency-resolution/src/packages/data-processor-2.0.0",
        LABS_ROOT / "tier-1-package-security/1.2-dependency-confusion/src/packages/wl-auth-1.0.0",
        LABS_ROOT / "tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils",
        LABS_ROOT / "tier-1-package-security/1.3-typosquatting/src/packages/requests-legit",
    )
    for package in packages:
        build_and_upload_pypi_package(package, PYPI_PRIVATE_UPLOAD)
    ok("PyPI Private seeded.")
    print()


def seed_pypi_public() -> None:
    print(f"{Style.BOLD}--- Seeding PyPI Public ---{Style.NC}")
    packages = (
        LABS_ROOT / "tier-1-package-security/1.1-dependency-resolution/src/packages/internal-utils-99.0.0",
        LABS_ROOT / "tier-1-package-security/1.2-dependency-confusion/src/packages/wl-auth-99.0.0",
        LABS_ROOT / "tier-0-foundations/0.2-package-managers/src/packages/malicious-utils",
        LABS_ROOT / "tier-1-package-security/1.3-typosquatting/src/packages/reqeusts-typo",
    )
    for package in packages:
        build_and_upload_pypi_package(package, PYPI_PUBLIC_UPLOAD)
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        source = LABS_ROOT / "tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils-backdoor"
        _copy_tree(source, temp_path)
        setup_path = temp_path / "setup.py"
        init_path = temp_path / "flask_utils" / "__init__.py"
        setup_path.write_text(setup_path.read_text().replace('version="1.0.0"', 'version="1.0.1"'))
        if init_path.exists():
            init_path.write_text(init_path.read_text().replace('__version__ = "1.0.0"', '__version__ = "1.0.1"'))
        build_and_upload_pypi_package(temp_path, PYPI_PUBLIC_UPLOAD)
    ok("PyPI Public seeded.")
    print()


def _write_file(path: Path, content: str, *, executable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    if executable:
        path.chmod(0o755)


def _npm_publish(package_dir: Path) -> None:
    package_json = json.loads((package_dir / "package.json").read_text())
    package_name = package_json["name"]
    package_version = package_json["version"]
    info(f"  Publishing {package_name}@{package_version}...")
    result = subprocess.run(
        ["npm", "publish", "--registry", VERDACCIO_URL],
        cwd=package_dir,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0 and "previously published" not in (result.stdout + result.stderr):
        warn(f"  npm publish reported a problem for {package_name}@{package_version}")
    ok(f"  {package_name}@{package_version} published")


def _verdaccio_token() -> str:
    unique_user = f"labuser-{int(time.time())}"
    payload = {"name": unique_user, "password": secrets.token_urlsafe(18)}
    _, response, _ = request_json("PUT", f"{VERDACCIO_URL}/-/user/org.couchdb.user:{unique_user}", payload)
    token = str(response.get("token", ""))
    if token:
        return token
    _, response, _ = request_json("PUT", f"{VERDACCIO_URL}/-/user/org.couchdb.user:{unique_user}", payload)
    token = str(response.get("token", ""))
    if not token:
        raise RuntimeError("Failed to get Verdaccio auth token")
    return token


def _publish_crafted_widget(token: str) -> None:
    info("  Publishing crafted-widget with manifest confusion...")
    package_dir = LABS_ROOT / "tier-1-package-security/1.5-manifest-confusion/src/packages/crafted-widget"
    subprocess.run(["npm", "pack"], cwd=package_dir, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    tarballs = sorted(package_dir.glob("crafted-widget-*.tgz"))
    if not tarballs:
        warn("  Could not pack crafted-widget, skipping manifest confusion")
        ok("  crafted-widget published")
        return
    tarball = tarballs[0]
    tarball_bytes = tarball.read_bytes()
    payload = {
        "_id": "crafted-widget",
        "name": "crafted-widget",
        "description": "A helpful widget library",
        "dist-tags": {"latest": "2.1.0"},
        "versions": {
            "2.1.0": {
                "name": "crafted-widget",
                "version": "2.1.0",
                "description": "A helpful widget library",
                "main": "index.js",
                "dependencies": {"lodash": "^4.17.21"},
                "scripts": {},
                "_id": "crafted-widget@2.1.0",
                "_nodeVersion": "20.0.0",
                "_npmVersion": "10.0.0",
                "dist": {
                    "shasum": hashlib.sha1(tarball_bytes).hexdigest(),
                    "integrity": f"sha512-{base64.b64encode(hashlib.sha512(tarball_bytes).digest()).decode()}",
                    "tarball": f"{VERDACCIO_URL}/crafted-widget/-/crafted-widget-2.1.0.tgz",
                },
            }
        },
        "_attachments": {
            "crafted-widget-2.1.0.tgz": {
                "content_type": "application/octet-stream",
                "data": base64.b64encode(tarball_bytes).decode(),
                "length": len(tarball_bytes),
            }
        },
    }
    request_json(
        "PUT",
        f"{VERDACCIO_URL}/crafted-widget",
        payload,
        headers={"Authorization": f"Bearer {token}"},
        ok_statuses=(200, 201, 409),
    )
    tarball.unlink(missing_ok=True)
    time.sleep(1)
    ok("  crafted-widget published")


def seed_verdaccio() -> None:
    print(f"{Style.BOLD}--- Seeding Verdaccio ---{Style.NC}")
    info("Authenticating with Verdaccio...")
    token = _verdaccio_token()
    npmrc = Path.home() / ".npmrc"
    npmrc.write_text(f"//verdaccio:4873/:_authToken={token}\nregistry={VERDACCIO_URL}/\n")
    ok("Verdaccio authenticated.")

    with tempfile.TemporaryDirectory() as temp_dir:
        lodash_dir = Path(temp_dir) / "lodash"
        lodash_dir.mkdir()
        _write_file(
            lodash_dir / "package.json",
            json.dumps(
                {
                    "name": "lodash",
                    "version": "4.17.21",
                    "description": "Lodash stub for lab",
                    "main": "index.js",
                },
                indent=2,
            )
            + "\n",
        )
        _write_file(
            lodash_dir / "index.js",
            """module.exports = {
  capitalize: (s) => s ? s.charAt(0).toUpperCase() + s.slice(1) : '',
  isEmpty: (v) => !v || (typeof v === 'object' && Object.keys(v).length === 0),
  sortBy: (arr) => [...arr].sort((a, b) => a - b),
  uniq: (arr) => [...new Set(arr)],
  chunk: (arr, size) => { const r = []; for (let i = 0; i < arr.length; i += size) r.push(arr.slice(i, i + size)); return r; }
};
""",
        )
        _npm_publish(lodash_dir)

        debug_dir = Path(temp_dir) / "debug"
        debug_dir.mkdir()
        _write_file(
            debug_dir / "package.json",
            json.dumps(
                {
                    "name": "debug",
                    "version": "4.3.4",
                    "description": "Lightweight debugging utility",
                    "main": "index.js",
                },
                indent=2,
            )
            + "\n",
        )
        _write_file(
            debug_dir / "index.js",
            """module.exports = function createDebug(namespace) {
  const fn = function(...args) {
    if (process.env.DEBUG) {
      console.log(`[${namespace}]`, ...args);
    }
  };
  fn.enabled = !!process.env.DEBUG;
  fn.namespace = namespace;
  return fn;
};
""",
        )
        _npm_publish(debug_dir)

    _npm_publish(LABS_ROOT / "tier-1-package-security/1.5-manifest-confusion/src/packages/safe-utils")
    _npm_publish(LABS_ROOT / "tier-1-package-security/1.5-manifest-confusion/src/packages/evil-pkg")
    _publish_crafted_widget(token)
    _npm_publish(LABS_ROOT / "tier-1-package-security/1.6-phantom-dependencies/src/packages/wl-framework/v1")
    _npm_publish(LABS_ROOT / "tier-1-package-security/1.6-phantom-dependencies/src/packages/wl-framework/v2")
    _npm_publish(LABS_ROOT / "tier-1-package-security/1.6-phantom-dependencies/src/packages/debug-malicious")
    ok("Verdaccio seeded.")
    print()


def _git_commit(repo_dir: Path, title: str, body: str) -> None:
    subprocess.run(["git", "add", "-A"], cwd=repo_dir, check=True)
    subprocess.run(["git", "commit", "-q", "-m", title, "-m", body], cwd=repo_dir, check=True)


def _git_push(repo_dir: Path, remote: str, branch: str, *, set_upstream: bool = False) -> None:
    command = ["git", "-c", f"http.extraHeader={gitea_git_auth_header()}", "push", "-q"]
    if set_upstream:
        command.append("-u")
    command.extend([remote, branch])
    subprocess.run(command, cwd=repo_dir, check=False)


def _create_repo(name: str) -> None:
    request_json(
        "POST",
        f"{GITEA_URL}/api/v1/user/repos",
        {"name": name, "auto_init": False, "private": False, "default_branch": "main"},
        headers=basic_auth_header(GITEA_USER, GITEA_PASS),
        ok_statuses=(201, 409, 422),
    )


def _seed_web_app() -> None:
    info("Creating web-app repository...")
    _create_repo("web-app")
    with tempfile.TemporaryDirectory() as temp_dir:
        repo_dir = Path(temp_dir)
        subprocess.run(["git", "init", "-q"], cwd=repo_dir, check=True)

        _write_file(
            repo_dir / "src/app.py",
            """from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Welcome to the Web App!"

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
""",
        )
        _write_file(repo_dir / "requirements.txt", "flask==3.0.0\n")
        _write_file(
            repo_dir / "build.sh",
            """#!/bin/bash
echo "=== Building Web App ==="
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Running tests..."
python -m pytest tests/ || true
echo "Build complete!"
""",
            executable=True,
        )
        _write_file(
            repo_dir / "README.md",
            """# Web App

A simple Flask web application.

## Build

```bash
./build.sh
```

## Run

```bash
python src/app.py
```
""",
        )
        _git_commit(repo_dir, "Initial project setup", "Added Flask app with health endpoint, build script, and requirements.")

        _write_file(repo_dir / "tests/__init__.py", "")
        _write_file(
            repo_dir / "tests/test_app.py",
            '''def test_placeholder():
    """Placeholder test"""
    assert True
''',
        )
        _git_commit(repo_dir, "Add test framework", "Added pytest test directory with a placeholder test.")

        _write_file(
            repo_dir / "config.yml",
            """app:
  name: "web-app"
  version: "1.0.0"
  debug: false
  port: 5000

database:
  host: "localhost"
  port: 5432
  name: "webapp_db"
""",
        )
        _git_commit(repo_dir, "Add application configuration", "Added config.yml with app and database settings.")

        _write_file(
            repo_dir / "src/app.py",
            """import os
import yaml
from flask import Flask, jsonify

app = Flask(__name__)

def load_config():
    config_path = os.path.join(os.path.dirname(__file__), "..", "config.yml")
    with open(config_path) as f:
        return yaml.safe_load(f)

@app.route("/")
def home():
    return "Welcome to the Web App v1.0!"

@app.route("/health")
def health():
    return jsonify({"status": "ok", "version": "1.0.0"})

@app.route("/info")
def info():
    config = load_config()
    return jsonify({
        "app": config["app"]["name"],
        "version": config["app"]["version"]
    })

if __name__ == "__main__":
    config = load_config()
    app.run(
        host="0.0.0.0",
        port=config["app"]["port"],
        debug=config["app"]["debug"]
    )
""",
        )
        _write_file(repo_dir / "requirements.txt", "flask==3.0.0\npyyaml==6.0.1\n")
        _git_commit(
            repo_dir,
            "Load config from YAML file",
            "Updated app to read settings from config.yml. Added pyyaml dependency.\nAdded /info endpoint to expose app metadata.",
        )

        subprocess.run(["git", "checkout", "-q", "-b", "feature/add-logging"], cwd=repo_dir, check=True)
        _write_file(
            repo_dir / "src/logger.py",
            """import logging
import sys

def setup_logging(level="INFO"):
    logger = logging.getLogger("webapp")
    logger.setLevel(getattr(logging, level))
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    )
    logger.addHandler(handler)
    return logger
""",
        )
        _git_commit(repo_dir, "Add logging module", "Added centralized logging setup for the application.")
        subprocess.run(["git", "checkout", "-q", "main"], cwd=repo_dir, check=True)

        subprocess.run(
            ["git", "remote", "add", "origin", f"{GITEA_URL}/{GITEA_USER}/web-app.git"],
            cwd=repo_dir,
            check=True,
        )
        _git_push(repo_dir, "origin", "main", set_upstream=True)
        _git_push(repo_dir, "origin", "feature/add-logging")
    ok("web-app repository created (4 commits on main + feature branch).")


def _wheel_hash(package_dir: Path) -> str:
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        subprocess.run(["pip", "wheel", "--no-deps", "-w", str(temp_path), str(package_dir), "-q"], check=False)
        wheels = sorted(temp_path.glob("flask_utils-*.whl"))
        if not wheels:
            return "0" * 64
        return hashlib.sha256(wheels[0].read_bytes()).hexdigest()


def _seed_secure_app() -> None:
    info("Creating secure-app repository...")
    _create_repo("secure-app")
    with tempfile.TemporaryDirectory() as temp_dir:
        repo_dir = Path(temp_dir)
        subprocess.run(["git", "init", "-q"], cwd=repo_dir, check=True)

        _write_file(repo_dir / "requirements.in", "# Project dependencies\nflask-utils\n")
        _write_file(
            repo_dir / "app.py",
            '''"""Sample app using flask-utils."""
from flask_utils import json_response, validate_request

request_data = {"name": "Lab User", "email": "user@lab.local"}
valid, error = validate_request(["name", "email"], request_data)

if valid:
    response = json_response({"message": "User created", "user": request_data})
    print(f"[+] Success: {response}")
else:
    print(f"[-] Validation error: {error}")
''',
        )
        legit_hash = _wheel_hash(LABS_ROOT / "tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils")
        _write_file(
            repo_dir / "requirements.txt",
            f"""#
# This file is autogenerated by pip-compile with Python 3.11
#
flask-utils==1.0.0 \\
    --hash=sha256:{legit_hash}
""",
        )
        _write_file(
            repo_dir / "verify-lockfile.sh",
            """#!/bin/bash
set -uo pipefail
REQ_IN="${1:-requirements.in}"
REQ_TXT="${2:-requirements.txt}"
echo "[*] Regenerating lockfile from ${REQ_IN}..."
TMPFILE=$(mktemp)
pip-compile --generate-hashes \
    --index-url http://pypi-private:8080/simple/ \
    --trusted-host pypi-private \
    --quiet \
    "$REQ_IN" \
    --output-file "$TMPFILE" 2>/dev/null
DIFF=$(diff <(grep -v "^#" "$REQ_TXT" | grep -v "^$") <(grep -v "^#" "$TMPFILE" | grep -v "^$"))
rm -f "$TMPFILE"
if [[ -z "$DIFF" ]]; then
    echo "[+] Lockfile is consistent. No tampering detected."
    exit 0
fi
echo "[-] LOCKFILE MISMATCH DETECTED!"
echo "$DIFF" | sed 's/^/    /'
exit 1
""",
            executable=True,
        )
        _git_commit(repo_dir, "Initial commit: secure-app with flask-utils dependency", "")

        subprocess.run(
            ["git", "remote", "add", "origin", f"{GITEA_URL}/{GITEA_USER}/secure-app.git"],
            cwd=repo_dir,
            check=True,
        )
        _git_push(repo_dir, "origin", "main", set_upstream=True)

        subprocess.run(["git", "checkout", "-q", "-b", "update-deps"], cwd=repo_dir, check=True)
        backdoor_hash = _wheel_hash(LABS_ROOT / "tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils-backdoor")
        requirements_path = repo_dir / "requirements.txt"
        requirements_path.write_text(requirements_path.read_text().replace(legit_hash, backdoor_hash))
        _git_commit(
            repo_dir,
            "chore: update flask-utils to latest version",
            "Routine dependency update. Ran pip-compile to refresh the lockfile.",
        )
        _git_push(repo_dir, "origin", "update-deps")

    request_json(
        "POST",
        f"{GITEA_URL}/api/v1/repos/{GITEA_USER}/secure-app/pulls",
        {
            "title": "chore: update flask-utils to latest version",
            "body": "Routine dependency update.\n\nRan `pip-compile` to refresh the lockfile. No functional changes.\n\n---\n_Auto-generated by dependabot-like bot_",
            "head": "update-deps",
            "base": "main",
        },
        headers=basic_auth_header(GITEA_USER, GITEA_PASS),
        ok_statuses=(201, 409, 422),
    )
    ok("secure-app repository created with malicious PR.")


def seed_gitea() -> None:
    print(f"{Style.BOLD}--- Seeding Gitea ---{Style.NC}")
    info("Creating admin user...")
    try:
        request_json(
            "POST",
            f"{GITEA_URL}/api/v1/user/signup",
            {
                "username": GITEA_USER,
                "password": GITEA_PASS,
                "email": GITEA_EMAIL,
                "full_name": "WeakLink Admin",
            },
            ok_statuses=(201, 409, 422),
        )
    except Exception:
        form = urlencode(
            {
                "user_name": GITEA_USER,
                "password": GITEA_PASS,
                "retype": GITEA_PASS,
                "email": GITEA_EMAIL,
            }
        ).encode()
        http_request(
            "POST",
            f"{GITEA_URL}/user/sign_up",
            data=form,
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            ok_statuses=(200, 302, 303, 409, 422),
        )
    ok("Admin user ready.")
    _seed_web_app()
    _seed_secure_app()
    ok("Gitea seeded.")
    print()


def _append_digest(location: str, digest: str) -> str:
    separator = "&" if "?" in location else "?"
    return f"{location}{separator}digest=sha256:{digest}"


def _registry_location(headers: dict[str, str]) -> str:
    location = headers.get("Location") or headers.get("location") or ""
    if location.startswith("/"):
        return f"{REGISTRY_URL}{location}"
    return location


def push_oci_image(name: str, tag: str, content: str) -> None:
    info(f"  Pushing {name}:{tag}...")
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        marker_path = temp_path / "marker.txt"
        marker_path.write_text(content)
        layer_path = temp_path / "layer.tar.gz"
        with tarfile.open(layer_path, "w:gz") as archive:
            archive.add(marker_path, arcname="marker.txt")
        layer_bytes = layer_path.read_bytes()
        layer_digest = hashlib.sha256(layer_bytes).hexdigest()
        layer_upload = _registry_location(
            http_request("POST", f"{REGISTRY_URL}/v2/{name}/blobs/uploads/", ok_statuses=(202,))[2]
        )
        http_request(
            "PUT",
            _append_digest(layer_upload, layer_digest),
            data=layer_bytes,
            headers={"Content-Type": "application/octet-stream"},
            ok_statuses=(201,),
        )

        config_bytes = b'{"architecture":"amd64","os":"linux","config":{}}'
        config_digest = hashlib.sha256(config_bytes).hexdigest()
        config_upload = _registry_location(
            http_request("POST", f"{REGISTRY_URL}/v2/{name}/blobs/uploads/", ok_statuses=(202,))[2]
        )
        http_request(
            "PUT",
            _append_digest(config_upload, config_digest),
            data=config_bytes,
            headers={"Content-Type": "application/octet-stream"},
            ok_statuses=(201,),
        )

        manifest = {
            "schemaVersion": 2,
            "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
            "config": {
                "mediaType": "application/vnd.docker.container.image.v1+json",
                "size": len(config_bytes),
                "digest": f"sha256:{config_digest}",
            },
            "layers": [
                {
                    "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
                    "size": len(layer_bytes),
                    "digest": f"sha256:{layer_digest}",
                }
            ],
        }
        http_request(
            "PUT",
            f"{REGISTRY_URL}/v2/{name}/manifests/{tag}",
            data=json.dumps(manifest).encode(),
            headers={"Content-Type": "application/vnd.docker.distribution.manifest.v2+json"},
            ok_statuses=(201,),
        )
    ok(f"  {name}:{tag} pushed")


def seed_oci_registry() -> None:
    print(f"{Style.BOLD}--- Seeding OCI Registry ---{Style.NC}")
    push_oci_image("webapp", "1.0.0", "safe-image: webapp v1.0.0 -- no backdoor")
    push_oci_image("webapp", "latest", "safe-image: webapp v1.0.0 -- no backdoor")
    push_oci_image("webapp", "latest", "BACKDOORED: This image contains a backdoor! Environment variables have been exfiltrated.")
    ok("OCI Registry seeded (webapp:latest is now backdoored -- tag poisoning).")
    print()


def enabled_tiers() -> list[str]:
    return [str(tier) for tier in range(8) if os.getenv(f"TIER{tier}_ENABLED", "true") == "true"]


def main(argv: list[str] | None = None) -> int:
    argparse.ArgumentParser(prog="python -m weaklink_platform.seeding").parse_args(argv)
    print()
    print(f"{Style.BOLD}========================================{Style.NC}")
    print(f"{Style.BOLD}  WeakLink Labs — Setup{Style.NC}")
    print(f"{Style.BOLD}========================================{Style.NC}")
    print()
    print(f"  Enabled tiers: {' '.join(enabled_tiers())}")
    print()
    wait_for_service("PyPI Private", "http://pypi-private:8080/simple/")
    wait_for_service("PyPI Public", "http://pypi-public:8080/simple/")
    wait_for_service("Verdaccio", "http://verdaccio:4873/-/ping")
    wait_for_service("Gitea", "http://gitea:3000/api/v1/version")
    wait_for_service("OCI Registry", "http://registry:5000/v2/")
    print()
    seed_pypi_private()
    seed_pypi_public()
    seed_verdaccio()
    seed_gitea()
    seed_oci_registry()
    print(f"{Style.BOLD}========================================{Style.NC}")
    print(f"{Style.GREEN}{Style.BOLD}  WeakLink Labs setup complete!{Style.NC}")
    print(f"{Style.BOLD}========================================{Style.NC}")
    print()
    print("  PyPI Private: 7 legitimate packages")
    print("  PyPI Public:  5 malicious packages")
    print("  Verdaccio:    7+ npm packages (incl. manifest confusion)")
    print("  Gitea:        2 repos (web-app, secure-app with malicious PR)")
    print("  OCI Registry: webapp:latest (backdoored via tag poisoning)")
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
