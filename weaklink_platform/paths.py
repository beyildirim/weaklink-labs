from __future__ import annotations

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
LABS_ROOT = REPO_ROOT / "labs"
GUIDE_ROOT = REPO_ROOT / "guide"
GUIDE_LABS_ROOT = GUIDE_ROOT / "docs" / "labs"
HOST_STATE_DIR = REPO_ROOT / ".weaklink" / "host"
HOST_PORT_FORWARD_DIR = HOST_STATE_DIR / "port-forwards"
PROGRESS_DIR = Path.home() / ".weaklink"


def ensure_host_state_dir() -> Path:
    HOST_PORT_FORWARD_DIR.mkdir(parents=True, exist_ok=True)
    return HOST_PORT_FORWARD_DIR


def ensure_progress_dir() -> Path:
    PROGRESS_DIR.mkdir(parents=True, exist_ok=True)
    return PROGRESS_DIR
