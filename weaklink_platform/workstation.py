from __future__ import annotations

import argparse
import os
import shlex
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path


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


def _run_lab_hook(lab_work: Path, app_root: Path, env_file: Path) -> str:
    hook = lab_work / "lab-init.sh"
    if not hook.exists() or not os.access(hook, os.X_OK):
        return str(app_root)
    env_file.unlink(missing_ok=True)
    sentinel = "__WEAKLINK_WORKDIR__="
    quoted_hook = shlex.quote(str(hook))
    quoted_env_file = shlex.quote(str(env_file))
    command = (
        f"WORKDIR={shlex.quote(str(app_root))}\n"
        f"source {quoted_hook} >&2\n"
        f"if [ -f {quoted_env_file} ]; then\n"
        f"  source {quoted_env_file}\n"
        "fi\n"
        f'printf "{sentinel}%s\\n" "${{WORKDIR:-/app}}"\n'
    )
    result = subprocess.run(["bash", "-lc", command], capture_output=True, text=True, check=False)
    for line in reversed(result.stdout.splitlines()):
        if line.startswith(sentinel):
            workdir = line.removeprefix(sentinel).strip()
            return workdir or str(app_root)
    return str(app_root)


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

    workdir = _run_lab_hook(lab_work, paths.app_root, paths.env_file)

    for pattern in ("Dockerfile.*", "build-packages.sh", "entrypoint.sh", "lab-init.sh", "packages"):
        for path in paths.app_root.glob(pattern):
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()

    paths.current_lab_file.write_text(lab_id)
    paths.workdir_file.write_text(workdir)
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
