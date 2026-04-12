from __future__ import annotations

import importlib.util
from pathlib import Path

from weaklink_platform.lab_runtime import InitContext
from weaklink_platform.registry_seed import reset_path, write_npmrc
from weaklink_platform.runner_seed import create_simulated_runner


REPO_ROOT = Path(__file__).resolve().parents[2]
EXPECTED_SHELL_FILES = {
    "labs/tier-0-foundations/0.4-how-cicd-works/src/repo/deploy.sh",
    "labs/tier-1-package-security/1.3-typosquatting/src/scripts/install_deps.sh",
    "labs/tier-1-package-security/1.4-lockfile-injection/src/scripts/verify-lockfile.sh",
    "labs/tier-2-build-cicd/2.3-indirect-ppe/src/repo/scripts/run-tests.sh",
    "labs/tier-2-build-cicd/2.5-self-hosted-runners/src/scripts/pre-job-cleanup.sh",
    "labs/tier-6-advanced-emerging/6.7-case-study-codecov/src/scripts/malicious-uploader.sh",
}
FORBIDDEN_DOC_REFERENCES = (
    "setup-repo.sh",
    "setup-registry.sh",
    "seed-repo.sh",
    "simulate-runner.sh",
    "check-compromise.sh",
    "validate_packages.sh",
    "compare-manifests.sh",
    "publish-attack.sh",
)


def _load_module(relative_path: str, module_name: str):
    module_path = REPO_ROOT / relative_path
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _make_context(tmp_path: Path, lab_id: str, *, lab_root: Path | None = None) -> InitContext:
    resolved_lab_root = lab_root or (tmp_path / "lab")
    resolved_lab_root.mkdir(parents=True, exist_ok=True)
    app_root = tmp_path / "app"
    repos_root = tmp_path / "repos"
    workspace_root = tmp_path / "workspace"
    app_root.mkdir(parents=True, exist_ok=True)
    repos_root.mkdir(parents=True, exist_ok=True)
    workspace_root.mkdir(parents=True, exist_ok=True)
    return InitContext(
        lab_id=lab_id,
        lab_root=resolved_lab_root,
        app_root=app_root,
        repos_root=repos_root,
        workspace_root=workspace_root,
        lab_src_link=tmp_path / "lab-link" / "src",
        env_file=tmp_path / "tmp" / ".weaklink-env",
        default_workdir=app_root,
    )


def test_shell_allowlist_matches_repo_policy() -> None:
    actual = {path.relative_to(REPO_ROOT).as_posix() for path in (REPO_ROOT / "labs").rglob("*.sh")}
    assert actual == EXPECTED_SHELL_FILES


def test_docs_do_not_reference_removed_shell_entrypoints() -> None:
    doc_roots = [
        REPO_ROOT / "guide" / "docs",
        REPO_ROOT / "labs" / "tier-1-package-security" / "1.2-dependency-confusion",
        REPO_ROOT / "labs" / "tier-1-package-security" / "1.3-typosquatting",
        REPO_ROOT / "labs" / "tier-1-package-security" / "1.5-manifest-confusion",
        REPO_ROOT / "labs" / "tier-1-package-security" / "1.6-phantom-dependencies",
    ]
    for root in doc_roots:
        for path in root.rglob("*"):
            if path.suffix not in {".md", ".py"}:
                continue
            text = path.read_text()
            for reference in FORBIDDEN_DOC_REFERENCES:
                assert reference not in text, f"{reference} still referenced in {path}"


def test_write_npmrc_writes_expected_registry_config(tmp_path: Path) -> None:
    npmrc_path = write_npmrc("token-123", registry_url="http://verdaccio:4873", npmrc_path=tmp_path / ".npmrc")
    assert npmrc_path.read_text() == "//verdaccio:4873/:_authToken=token-123\nregistry=http://verdaccio:4873/\n"


def test_reset_path_recreates_empty_directory(tmp_path: Path) -> None:
    target = tmp_path / "payload"
    target.mkdir()
    (target / "note.txt").write_text("keep nothing\n")

    reset_path(target)

    assert target.exists()
    assert list(target.iterdir()) == []


def test_create_simulated_runner_creates_expected_layout(tmp_path: Path) -> None:
    runner_dir = tmp_path / "runner"
    create_simulated_runner(runner_dir)

    assert (runner_dir / "workspace" / ".bashrc").exists()
    assert (runner_dir / "hooks").is_dir()
    assert (runner_dir / "config").is_dir()
    run_job = runner_dir / "run-job.sh"
    assert run_job.exists()
    assert run_job.stat().st_mode & 0o111
    assert "RUNNER_NAME" in (runner_dir / "workspace" / ".bashrc").read_text()


def test_lab_0_1_init_uses_python_seed_path(monkeypatch, tmp_path: Path) -> None:
    module = _load_module(
        "labs/tier-0-foundations/0.1-version-control/src/lab_init.py",
        "lab_0_1_init",
    )
    persistent_seed_dir = tmp_path / "seed-work"

    class _TempDir:
        def __enter__(self) -> str:
            persistent_seed_dir.mkdir(parents=True, exist_ok=True)
            return str(persistent_seed_dir)

        def __exit__(self, exc_type, exc, tb) -> bool:
            return False

    calls: list[tuple[str, object]] = []
    monkeypatch.setattr(module, "TemporaryDirectory", lambda: _TempDir())
    monkeypatch.setattr(module, "wait_for_http", lambda url: calls.append(("wait", url)))
    monkeypatch.setattr(
        module,
        "reset_gitea_repo",
        lambda repo_name, delete_existing=True: calls.append(("reset", (repo_name, delete_existing))),
    )
    monkeypatch.setattr(
        module,
        "init_git_repo",
        lambda repo_dir, **kwargs: calls.append(("init", (repo_dir, kwargs))),
    )
    monkeypatch.setattr(
        module,
        "commit_all",
        lambda repo_dir, subject, body=None: calls.append(("commit", (subject, body))),
    )
    monkeypatch.setattr(
        module,
        "checkout_git_branch",
        lambda repo_dir, branch, create=False: calls.append(("checkout", (branch, create))),
    )
    monkeypatch.setattr(
        module,
        "push_git_branch",
        lambda repo_dir, repo_name, branch, set_upstream=False: calls.append(
            ("push", (repo_name, branch, set_upstream))
        ),
    )

    context = _make_context(tmp_path, "0.1")
    result = module.run(context)

    assert result.workdir == context.workspace_root
    assert ("wait", f"{module.GITEA_URL}/api/v1/version") in calls
    assert ("reset", ("web-app", True)) in calls
    commit_subjects = [payload[0] for action, payload in calls if action == "commit"]
    assert commit_subjects == [
        "Initial project setup",
        "Add test framework",
        "Add application configuration",
        "Load config from YAML file",
        "Add logging module",
    ]
    assert ("checkout", ("feature/add-logging", True)) in calls
    assert ("push", ("web-app", "main", True)) in calls
    assert ("push", ("web-app", "feature/add-logging", False)) in calls
    assert (persistent_seed_dir / "build.sh").exists()
    assert (persistent_seed_dir / "src" / "logger.py").exists()


def test_lab_1_6_init_resets_registry_to_safe_state(monkeypatch, tmp_path: Path) -> None:
    module = _load_module(
        "labs/tier-1-package-security/1.6-phantom-dependencies/src/lab_init.py",
        "lab_1_6_init",
    )
    lab_root = tmp_path / "lab"
    (lab_root / "packages" / "wl-framework" / "v1").mkdir(parents=True, exist_ok=True)
    marker = Path("/tmp/phantom-dep-pwned")
    marker.write_text("pwned\n")
    actions: list[tuple[str, object]] = []
    monkeypatch.setattr(module, "prepare_verdaccio", lambda: actions.append(("prepare", None)))
    monkeypatch.setattr(module, "npm_unpublish", lambda spec: actions.append(("unpublish", spec)))
    monkeypatch.setattr(
        module,
        "publish_inline_package",
        lambda manifest, files: actions.append(("publish_inline", manifest["name"])),
    )
    monkeypatch.setattr(module, "npm_publish", lambda path: actions.append(("publish_dir", path)))

    context = _make_context(tmp_path, "1.6", lab_root=lab_root)
    result = module.run(context)

    assert result.workdir == context.default_workdir
    assert actions == [
        ("prepare", None),
        ("unpublish", "wl-framework@2.0.0"),
        ("unpublish", "debug@99.0.0"),
        ("publish_inline", "ms"),
        ("publish_inline", "debug"),
        ("publish_dir", lab_root / "packages" / "wl-framework" / "v1"),
    ]
    assert not marker.exists()


def test_lab_2_5_init_uses_runner_seed_helper(monkeypatch, tmp_path: Path) -> None:
    module = _load_module(
        "labs/tier-2-build-cicd/2.5-self-hosted-runners/src/lab_init.py",
        "lab_2_5_init",
    )
    lab_root = tmp_path / "lab"
    (lab_root / "repo").mkdir(parents=True, exist_ok=True)
    actions: list[tuple[str, object]] = []
    monkeypatch.setattr(
        module,
        "reset_gitea_repo",
        lambda repo_name, delete_existing=True: actions.append(("reset", (repo_name, delete_existing))),
    )
    monkeypatch.setattr(
        module,
        "seed_git_repo_from_source",
        lambda **kwargs: actions.append(("seed_repo", kwargs)),
    )
    monkeypatch.setattr(
        module,
        "create_gitea_user",
        lambda username, password, email: actions.append(("create_user", (username, password, email))),
    )
    monkeypatch.setattr(module, "create_simulated_runner", lambda: actions.append(("runner", None)))

    context = _make_context(tmp_path, "2.5", lab_root=lab_root)
    result = module.run(context)

    assert result.workdir == context.default_workdir
    assert actions[0] == ("reset", ("wl-webapp", True))
    assert actions[1][0] == "seed_repo"
    assert actions[1][1]["source_dir"] == lab_root / "repo"
    assert actions[1][1]["repo_dir"] == context.repos_root / "wl-webapp"
    assert actions[1][1]["repo_name"] == "wl-webapp"
    assert actions[1][1]["force_push"] is True
    assert actions[2] == ("create_user", ("attacker", "password", "attacker@evil.com"))
    assert actions[3] == ("runner", None)
