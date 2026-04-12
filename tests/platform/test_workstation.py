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
    (golden_lab / "lab_init.py").write_text(
        """
from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    target = context.workspace_root / "custom"
    target.mkdir(parents=True, exist_ok=True)
    return InitResult(workdir=target, env={"SECRET_API_KEY": "test"})


if __name__ == "__main__":
    raise SystemExit(main_init(run))
"""
    )

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


def test_initialize_lab_without_hook_uses_default_workdir(tmp_path: Path) -> None:
    paths = _make_paths(tmp_path)
    golden_lab = paths.golden_root / "2.1"
    golden_lab.mkdir(parents=True)

    exit_code = initialize_lab("2.1", paths=paths)

    assert exit_code == 0
    assert paths.workdir_file.read_text() == str(paths.app_root)
