from __future__ import annotations

from pathlib import Path
from tempfile import TemporaryDirectory

from weaklink_platform.gitea_seed import (
    GITEA_URL,
    checkout_git_branch,
    commit_all,
    init_git_repo,
    push_git_branch,
    reset_gitea_repo,
)
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init
from weaklink_platform.registry_seed import wait_for_http


def _write_file(path: Path, content: str, *, executable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    if executable:
        path.chmod(0o755)


def _seed_repo_history(repo_dir: Path, repo_name: str) -> None:
    init_git_repo(repo_dir, user_name="Lab Admin", user_email="admin@lab.local")

    _write_file(
        repo_dir / "src" / "app.py",
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
# Build script for the web application
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
    commit_all(
        repo_dir,
        "Initial project setup",
        body="Added Flask app with health endpoint, build script, and requirements.",
    )

    _write_file(repo_dir / "tests" / "__init__.py", "")
    _write_file(
        repo_dir / "tests" / "test_app.py",
        '''def test_placeholder():
    """Placeholder test"""
    assert True
''',
    )
    commit_all(
        repo_dir,
        "Add test framework",
        body="Added pytest test directory with a placeholder test.",
    )

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
    commit_all(
        repo_dir,
        "Add application configuration",
        body="Added config.yml with app and database settings.",
    )

    _write_file(
        repo_dir / "src" / "app.py",
        """import os
import yaml
from flask import Flask, jsonify

app = Flask(__name__)

def load_config():
    config_path = os.path.join(os.path.dirname(__file__), "..", "config.yml")
    with open(config_path) as handle:
        return yaml.safe_load(handle)

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
        "version": config["app"]["version"],
    })

if __name__ == "__main__":
    config = load_config()
    app.run(
        host="0.0.0.0",
        port=config["app"]["port"],
        debug=config["app"]["debug"],
    )
""",
    )
    _write_file(repo_dir / "requirements.txt", "flask==3.0.0\npyyaml==6.0.1\n")
    commit_all(
        repo_dir,
        "Load config from YAML file",
        body="Updated app to read settings from config.yml. Added pyyaml dependency.\nAdded /info endpoint to expose app metadata.",
    )

    checkout_git_branch(repo_dir, "feature/add-logging", create=True)
    _write_file(
        repo_dir / "src" / "logger.py",
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
    commit_all(
        repo_dir,
        "Add logging module",
        body="Added centralized logging setup for the application.",
    )

    checkout_git_branch(repo_dir, "main")
    push_git_branch(repo_dir, repo_name, "main", set_upstream=True)
    push_git_branch(repo_dir, repo_name, "feature/add-logging")


def run(context: InitContext) -> InitResult:
    repo_name = "web-app"
    wait_for_http(f"{GITEA_URL}/api/v1/version")
    reset_gitea_repo(repo_name, delete_existing=True)
    with TemporaryDirectory() as temp_dir:
        _seed_repo_history(Path(temp_dir), repo_name)
    return InitResult(workdir=context.workspace_root)


if __name__ == '__main__':
    raise SystemExit(main_init(run))
