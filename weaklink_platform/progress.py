from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

from weaklink_platform.paths import PROGRESS_DIR, ensure_progress_dir


def progress_file(lab_id: str, suffix: str) -> Path:
    ensure_progress_dir()
    return PROGRESS_DIR / f"{lab_id}.{suffix}"


def is_completed(lab_id: str) -> bool:
    return progress_file(lab_id, "completed").exists()


def mark_completed(lab_id: str) -> None:
    progress_file(lab_id, "completed").write_text(datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))


def completed_at(lab_id: str) -> str | None:
    path = progress_file(lab_id, "completed")
    if not path.exists():
        return None
    return path.read_text().strip()


def get_hint_count(lab_id: str) -> int:
    path = progress_file(lab_id, "hints")
    if not path.exists():
        return 0
    return int(path.read_text().strip() or "0")


def increment_hint(lab_id: str) -> int:
    count = get_hint_count(lab_id) + 1
    progress_file(lab_id, "hints").write_text(str(count))
    return count


def reset_progress(lab_id: str) -> None:
    for suffix in ("completed", "hints"):
        path = progress_file(lab_id, suffix)
        if path.exists():
            path.unlink()
