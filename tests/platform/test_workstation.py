from pathlib import Path

from weaklink_platform.workstation import WorkstationPaths, initialize_lab, reset_lab


def _make_paths(tmp_path: Path) -> WorkstationPaths:
    return WorkstationPaths(
        golden_root=tmp_path / "golden",
        labs_root=tmp_path / "labs",
        app_root=tmp_path / "app",
        lab_src_link=tmp_path / "lab" / "src",
        repos_root=tmp_path / "repos",
        workspace_root=tmp_path / "workspace",
        env_file=tmp_path / "tmp" / ".weaklink-env",
        current_lab_file=tmp_path / "tmp" / ".weaklink-current-lab",
        workdir_file=tmp_path / "tmp" / ".weaklink-workdir",
    )


def test_initialize_lab_copies_files_and_tracks_workdir(tmp_path: Path) -> None:
    paths = _make_paths(tmp_path)
    golden_lab = paths.golden_root / "1.0"
    (golden_lab / "app").mkdir(parents=True)
    (golden_lab / "app" / "hello.txt").write_text("hello\n")
    (golden_lab / "packages").mkdir()
    (golden_lab / "build-packages.sh").write_text("echo build\n")
    hook = golden_lab / "lab-init.sh"
    hook.write_text(
        f"""#!/bin/bash
mkdir -p "{paths.workspace_root / 'custom'}"
echo 'export SECRET_API_KEY=\"test\"' > "{paths.env_file}"
WORKDIR="{paths.workspace_root / 'custom'}"
"""
    )
    hook.chmod(0o755)

    exit_code = initialize_lab("1.0", paths=paths)

    assert exit_code == 0
    assert (paths.app_root / "hello.txt").read_text() == "hello\n"
    assert not (paths.app_root / "packages").exists()
    assert not (paths.app_root / "build-packages.sh").exists()
    assert paths.current_lab_file.read_text() == "1.0"
    assert paths.workdir_file.read_text() == str(paths.workspace_root / "custom")
    assert paths.env_file.exists()
    assert paths.lab_src_link.is_symlink()


def test_reset_lab_uses_current_lab_file_when_no_argument(tmp_path: Path) -> None:
    paths = _make_paths(tmp_path)
    golden_lab = paths.golden_root / "2.0"
    golden_lab.mkdir(parents=True)
    (golden_lab / "note.txt").write_text("hi\n")
    paths.current_lab_file.parent.mkdir(parents=True, exist_ok=True)
    paths.current_lab_file.write_text("2.0")

    exit_code = reset_lab(paths=paths)

    assert exit_code == 0
    assert (paths.app_root / "note.txt").read_text() == "hi\n"


def test_initialize_lab_tolerates_nonzero_hook_and_uses_env_workdir(tmp_path: Path) -> None:
    paths = _make_paths(tmp_path)
    golden_lab = paths.golden_root / "2.1"
    golden_lab.mkdir(parents=True)
    hook = golden_lab / "lab-init.sh"
    hook.write_text(
        f"""#!/bin/bash
echo "[setup] creating repo"
echo 'export WORKDIR="{paths.workspace_root / "repo"}"' > "{paths.env_file}"
bash -lc 'exit 1'
"""
    )
    hook.chmod(0o755)

    exit_code = initialize_lab("2.1", paths=paths)

    assert exit_code == 0
    assert paths.workdir_file.read_text() == str(paths.workspace_root / "repo")


def test_initialize_lab_prefers_python_hook_over_shell(tmp_path: Path) -> None:
    paths = _make_paths(tmp_path)
    golden_lab = paths.golden_root / "3.0"
    golden_lab.mkdir(parents=True)
    (golden_lab / "lab_init.py").write_text(
        """
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    return InitResult(
        workdir=context.workspace_root / "python-hook",
        env={"FROM_PYTHON": "yes"},
    )


if __name__ == "__main__":
    raise SystemExit(main_init(run))
"""
    )
    hook = golden_lab / "lab-init.sh"
    hook.write_text(
        f"""#!/bin/bash
echo 'export FROM_SHELL=yes' > "{paths.env_file}"
WORKDIR="{paths.workspace_root / 'shell-hook'}"
"""
    )
    hook.chmod(0o755)

    exit_code = initialize_lab("3.0", paths=paths)

    assert exit_code == 0
    assert paths.workdir_file.read_text() == str(paths.workspace_root / "python-hook")
    assert "FROM_PYTHON" in paths.env_file.read_text()
