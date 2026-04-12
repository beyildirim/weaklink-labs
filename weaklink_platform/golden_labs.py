from __future__ import annotations

import shutil
from pathlib import Path

from weaklink_platform.manifest import load_lab_manifest


def stage_golden_labs(raw_root: Path, target_root: Path) -> None:
    target_root.mkdir(parents=True, exist_ok=True)

    for lab_dir in sorted(raw_root.glob("tier-*/*")):
        if not lab_dir.is_dir() or not (lab_dir / "lab.yml").exists():
            continue

        manifest = load_lab_manifest(lab_dir)
        target_dir = target_root / manifest.id
        src_dir = lab_dir / "src"
        if src_dir.exists():
            shutil.copytree(src_dir, target_dir, dirs_exist_ok=True)
        else:
            target_dir.mkdir(parents=True, exist_ok=True)

        verify_py = lab_dir / "verify.py"
        if verify_py.exists():
            shutil.copy2(verify_py, target_dir / "verify.py")
