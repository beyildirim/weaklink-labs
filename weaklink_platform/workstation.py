from __future__ import annotations

import argparse
import shutil
from dataclasses import dataclass
from pathlib import Path

from weaklink_platform.lab_runtime import InitResult, write_env_exports


@dataclass(frozen=True)
class WorkstationPaths:
    golden_root: Path = Path("/opt/labs")
    labs_root: Path = Path("/home/labs")
    app_root: Path = Path("/app")
    lab_src_link: Path = Path("/lab/src")
    repos_root: Path = Path("/repos")
    workspace_root: Path = Path("/workspace")
    env_file: Path = Path("/tmp/.weaklink-env")
    current_lab_file: Path = Path("/tmp/.weaklink-current-lab")
    workdir_file: Path = Path("/tmp/.weaklink-workdir")


def _remove_children(path: Path) -> None:
    if not path.exists():
        path.mkdir(parents=True, exist_ok=True)
        return
    for child in path.iterdir():
        if child.is_dir() and not child.is_symlink():
            shutil.rmtree(child)
        else:
            child.unlink()


def _copy_children(source: Path, destination: Path) -> None:
    if not source.exists():
        return
    destination.mkdir(parents=True, exist_ok=True)
    for child in source.iterdir():
        target = destination / child.name
        if child.is_dir():
            shutil.copytree(child, target, dirs_exist_ok=True)
        else:
            shutil.copy2(child, target)


def _run_lab_hook(lab_id: str, lab_work: Path, *, paths: WorkstationPaths) -> InitResult:
    from weaklink_platform.lab_runtime import execute_lab_init

    return execute_lab_init(
        lab_id=lab_id,
        lab_root=lab_work,
        app_root=paths.app_root,
        repos_root=paths.repos_root,
        workspace_root=paths.workspace_root,
        lab_src_link=paths.lab_src_link,
        env_file=paths.env_file,
    )


def initialize_lab(lab_id: str, *, paths: WorkstationPaths = WorkstationPaths()) -> int:
    golden = paths.golden_root / lab_id
    if not golden.exists():
        print(f"Lab {lab_id}: no source files found.")
        return 0

    paths.env_file.parent.mkdir(parents=True, exist_ok=True)
    paths.current_lab_file.parent.mkdir(parents=True, exist_ok=True)
    paths.workdir_file.parent.mkdir(parents=True, exist_ok=True)
    paths.env_file.unlink(missing_ok=True)

    lab_work = paths.labs_root / lab_id
    if lab_work.exists():
        shutil.rmtree(lab_work)
    shutil.copytree(golden, lab_work)

    _remove_children(paths.app_root)
    if paths.lab_src_link.exists() or paths.lab_src_link.is_symlink():
        if paths.lab_src_link.is_dir() and not paths.lab_src_link.is_symlink():
            shutil.rmtree(paths.lab_src_link)
        else:
            paths.lab_src_link.unlink()
    paths.lab_src_link.parent.mkdir(parents=True, exist_ok=True)
    paths.lab_src_link.symlink_to(lab_work, target_is_directory=True)

    if paths.repos_root.exists():
        _remove_children(paths.repos_root)
    if paths.workspace_root.exists():
        _remove_children(paths.workspace_root)

    _copy_children(lab_work, paths.app_root)
    nested_app = paths.app_root / "app"
    if nested_app.exists():
        _copy_children(nested_app, paths.app_root)
        shutil.rmtree(nested_app)

    init_result = _run_lab_hook(lab_id, lab_work, paths=paths)
    write_env_exports(paths.env_file, init_result.env)

    for pattern in ("Dockerfile.*", "build-packages.sh", "entrypoint.sh", "lab_init.py", "verify.py", "packages"):
        for path in paths.app_root.glob(pattern):
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()

    paths.current_lab_file.write_text(lab_id)
    paths.workdir_file.write_text(str(init_result.workdir))
    print(f"Lab {lab_id} initialized.")
    return 0


def reset_lab(lab_id: str | None = None, *, paths: WorkstationPaths = WorkstationPaths()) -> int:
    resolved_lab_id = lab_id
    if not resolved_lab_id and paths.current_lab_file.exists():
        resolved_lab_id = paths.current_lab_file.read_text().strip()
    if not resolved_lab_id:
        print("Usage: lab-reset [lab-id]")
        return 1
    return initialize_lab(resolved_lab_id, paths=paths)


def main_lab_init(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="lab-init")
    parser.add_argument("lab_id")
    args = parser.parse_args(argv)
    return initialize_lab(args.lab_id)


def main_lab_reset(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="lab-reset")
    parser.add_argument("lab_id", nargs="?")
    args = parser.parse_args(argv)
    return reset_lab(args.lab_id)
