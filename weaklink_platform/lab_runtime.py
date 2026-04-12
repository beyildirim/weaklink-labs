from __future__ import annotations

import argparse
import json
import os
import shlex
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Sequence


CURRENT_LAB_FILE = Path("/tmp/.weaklink-current-lab")
CURRENT_WORKDIR_FILE = Path("/tmp/.weaklink-workdir")
DEFAULT_APP_ROOT = Path("/app")
DEFAULT_REPOS_ROOT = Path("/repos")
DEFAULT_WORKSPACE_ROOT = Path("/workspace")
DEFAULT_LABS_ROOT = Path("/opt/labs")


def _package_root() -> Path:
    return Path(__file__).resolve().parent.parent


@dataclass(frozen=True)
class InitContext:
    lab_id: str
    lab_root: Path
    app_root: Path
    repos_root: Path
    workspace_root: Path
    lab_src_link: Path
    env_file: Path
    default_workdir: Path


@dataclass(frozen=True)
class InitResult:
    workdir: Path
    env: dict[str, str] = field(default_factory=dict)

    def to_payload(self) -> dict[str, object]:
        return {"workdir": str(self.workdir), "env": dict(self.env)}


@dataclass(frozen=True)
class VerificationContext:
    lab_id: str
    lab_root: Path
    app_root: Path
    repos_root: Path
    workspace_root: Path
    workdir: Path


@dataclass(frozen=True)
class VerificationCheck:
    status: str
    message: str

    def to_payload(self) -> dict[str, str]:
        return {"status": self.status, "message": self.message}


@dataclass(frozen=True)
class VerificationResult:
    passed: bool
    checks: tuple[VerificationCheck, ...]
    error: str | None = None

    def to_payload(self) -> dict[str, object]:
        return {
            "passed": self.passed,
            "checks": [check.to_payload() for check in self.checks],
            "error": self.error,
        }


InitHook = Callable[[InitContext], InitResult]
Verifier = Callable[[VerificationContext], VerificationResult]


def _path_from_env(name: str, default: Path) -> Path:
    value = os.environ.get(name)
    return Path(value) if value else default


def _with_package_pythonpath(env: dict[str, str]) -> dict[str, str]:
    package_root = str(_package_root())
    current = env.get("PYTHONPATH", "")
    env["PYTHONPATH"] = package_root if not current else f"{package_root}{os.pathsep}{current}"
    return env


def load_init_context_from_env() -> InitContext:
    return InitContext(
        lab_id=os.environ.get("WEAKLINK_LAB_ID", ""),
        lab_root=_path_from_env("WEAKLINK_LAB_ROOT", Path.cwd()),
        app_root=_path_from_env("WEAKLINK_APP_ROOT", DEFAULT_APP_ROOT),
        repos_root=_path_from_env("WEAKLINK_REPOS_ROOT", DEFAULT_REPOS_ROOT),
        workspace_root=_path_from_env("WEAKLINK_WORKSPACE_ROOT", DEFAULT_WORKSPACE_ROOT),
        lab_src_link=_path_from_env("WEAKLINK_LAB_SRC_LINK", Path("/lab/src")),
        env_file=_path_from_env("WEAKLINK_ENV_FILE", Path("/tmp/.weaklink-env")),
        default_workdir=_path_from_env("WEAKLINK_DEFAULT_WORKDIR", DEFAULT_APP_ROOT),
    )


def load_verification_context_from_env() -> VerificationContext:
    return VerificationContext(
        lab_id=os.environ.get("LAB_ID", ""),
        lab_root=_path_from_env("WEAKLINK_LAB_ROOT", Path.cwd()),
        app_root=_path_from_env("WEAKLINK_APP_ROOT", DEFAULT_APP_ROOT),
        repos_root=_path_from_env("WEAKLINK_REPOS_ROOT", DEFAULT_REPOS_ROOT),
        workspace_root=_path_from_env("WEAKLINK_WORKSPACE_ROOT", DEFAULT_WORKSPACE_ROOT),
        workdir=_path_from_env("WEAKLINK_WORK_DIR", DEFAULT_APP_ROOT),
    )


def write_env_exports(path: Path, env: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not env:
        path.unlink(missing_ok=True)
        return
    lines = [f"export {name}={shlex.quote(value)}" for name, value in sorted(env.items())]
    path.write_text("\n".join(lines) + "\n")


def read_env_exports(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    env: dict[str, str] = {}
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line.removeprefix("export ").strip()
        name, separator, value = line.partition("=")
        if not separator or not name.strip():
            continue
        parsed = shlex.split(value.strip())
        env[name.strip()] = parsed[0] if parsed else ""
    return env


def main_init(callback: InitHook, argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)
    result = callback(load_init_context_from_env())
    if args.json:
        print(json.dumps(result.to_payload()))
    else:
        print(str(result.workdir))
    return 0


def main_verify(callback: Verifier, argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)
    result = callback(load_verification_context_from_env())
    if args.json:
        print(json.dumps(result.to_payload()))
    else:
        print_verification_result(result)
    return 0 if result.passed else 1


def print_verification_result(result: VerificationResult) -> None:
    labels = {"pass": "[PASS]", "fail": "[FAIL]", "info": "[INFO]"}
    for check in result.checks:
        print(f"{labels.get(check.status, '[INFO]')} {check.message}")
    if result.error:
        print(f"[ERROR] {result.error}")
    passed = sum(1 for check in result.checks if check.status == "pass")
    failed = sum(1 for check in result.checks if check.status == "fail")
    print(f"Results: {passed} passed, {failed} failed")


def run_command_checks(
    checks: Sequence[tuple[str, str]],
    *,
    env: dict[str, str] | None = None,
    cwd: Path | None = None,
) -> VerificationResult:
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)

    results: list[VerificationCheck] = []
    failed = False
    for description, command in checks:
        completed = subprocess.run(
            ["bash", "-lc", command],
            cwd=str(cwd) if cwd else None,
            env=merged_env,
            capture_output=True,
            text=True,
            check=False,
        )
        if completed.returncode == 0:
            results.append(VerificationCheck(status="pass", message=description))
            continue
        detail = (completed.stdout.strip() or completed.stderr.strip()).strip()
        message = description if not detail else f"{description}: {detail}"
        results.append(VerificationCheck(status="fail", message=message))
        failed = True
    return VerificationResult(passed=not failed, checks=tuple(results))


def parse_shell_verifier_output(stdout: str) -> tuple[VerificationCheck, ...]:
    checks: list[VerificationCheck] = []
    for raw_line in stdout.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        upper = line.upper()
        if "PASS" in upper or "✓" in line or "✅" in line:
            checks.append(VerificationCheck(status="pass", message=line))
        elif "FAIL" in upper or "✗" in line or "❌" in line:
            checks.append(VerificationCheck(status="fail", message=line))
        else:
            checks.append(VerificationCheck(status="info", message=line))
    return tuple(checks)


def verifier_exists(lab_dir: Path) -> bool:
    return (lab_dir / "verify.py").exists() or (lab_dir / "verify.sh").exists()


def _init_env(
    *,
    lab_id: str,
    lab_root: Path,
    app_root: Path,
    repos_root: Path,
    workspace_root: Path,
    lab_src_link: Path,
    env_file: Path,
) -> dict[str, str]:
    env = os.environ.copy()
    env.update(
        {
            "WEAKLINK_LAB_ID": lab_id,
            "WEAKLINK_LAB_ROOT": str(lab_root),
            "WEAKLINK_APP_ROOT": str(app_root),
            "WEAKLINK_REPOS_ROOT": str(repos_root),
            "WEAKLINK_WORKSPACE_ROOT": str(workspace_root),
            "WEAKLINK_LAB_SRC_LINK": str(lab_src_link),
            "WEAKLINK_ENV_FILE": str(env_file),
            "WEAKLINK_DEFAULT_WORKDIR": str(app_root),
        }
    )
    return _with_package_pythonpath(env)


def _resolve_init_hook(lab_root: Path, name: str) -> Path | None:
    candidates = (
        lab_root / "src" / name,
        lab_root / name,
    )
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def _execute_shell_init(hook: Path | None, *, app_root: Path, env_file: Path, env: dict[str, str]) -> InitResult:
    if hook is None or not hook.exists():
        return InitResult(workdir=app_root)

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
    completed = subprocess.run(
        ["bash", "-lc", command],
        capture_output=True,
        text=True,
        check=False,
        env=env,
    )
    workdir = app_root
    for line in reversed(completed.stdout.splitlines()):
        if line.startswith(sentinel):
            value = line.removeprefix(sentinel).strip()
            workdir = Path(value) if value else app_root
            break
    return InitResult(workdir=workdir, env=read_env_exports(env_file))


def execute_lab_init(
    *,
    lab_id: str,
    lab_root: Path,
    app_root: Path,
    repos_root: Path,
    workspace_root: Path,
    lab_src_link: Path,
    env_file: Path,
) -> InitResult:
    env = _init_env(
        lab_id=lab_id,
        lab_root=lab_root,
        app_root=app_root,
        repos_root=repos_root,
        workspace_root=workspace_root,
        lab_src_link=lab_src_link,
        env_file=env_file,
    )

    python_hook = _resolve_init_hook(lab_root, "lab_init.py")
    if python_hook is not None:
        env_file.unlink(missing_ok=True)
        completed = subprocess.run(
            ["python3", str(python_hook), "--json"],
            capture_output=True,
            text=True,
            check=False,
            env=env,
        )
        stdout = completed.stdout.strip()
        if stdout:
            try:
                payload = json.loads(stdout.splitlines()[-1])
                workdir = payload.get("workdir") or str(app_root)
                raw_env = payload.get("env") or {}
                parsed_env = {str(name): str(value) for name, value in dict(raw_env).items()}
                return InitResult(workdir=Path(str(workdir)), env=parsed_env)
            except (json.JSONDecodeError, TypeError, ValueError):
                pass
        return InitResult(workdir=app_root, env=read_env_exports(env_file))

    return _execute_shell_init(
        _resolve_init_hook(lab_root, "lab-init.sh"),
        app_root=app_root,
        env_file=env_file,
        env=env,
    )


def _verifier_env(lab_id: str, lab_dir: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["LAB_ID"] = lab_id
    env["WEAKLINK_LAB_ROOT"] = str(lab_dir)
    env.setdefault("WEAKLINK_APP_ROOT", str(DEFAULT_APP_ROOT))
    env.setdefault("WEAKLINK_REPOS_ROOT", str(DEFAULT_REPOS_ROOT))
    env.setdefault("WEAKLINK_WORKSPACE_ROOT", str(DEFAULT_WORKSPACE_ROOT))
    if CURRENT_LAB_FILE.exists() and CURRENT_LAB_FILE.read_text().strip() == lab_id and CURRENT_WORKDIR_FILE.exists():
        env["WEAKLINK_WORK_DIR"] = CURRENT_WORKDIR_FILE.read_text().strip()
    return _with_package_pythonpath(env)


def execute_lab_verifier(
    lab_id: str,
    *,
    lab_dir: Path | None = None,
    labs_root: Path = DEFAULT_LABS_ROOT,
    timeout: int = 30,
) -> VerificationResult:
    resolved_lab_dir = lab_dir or (labs_root / lab_id)
    env = _verifier_env(lab_id, resolved_lab_dir)

    python_verifier = resolved_lab_dir / "verify.py"
    shell_verifier = resolved_lab_dir / "verify.sh"

    try:
        if python_verifier.exists():
            completed = subprocess.run(
                ["python3", str(python_verifier), "--json"],
                capture_output=True,
                text=True,
                timeout=timeout,
                env=env,
                check=False,
            )
            stdout = completed.stdout.strip()
            if not stdout:
                error = completed.stderr.strip() or "verify.py produced no output"
                return VerificationResult(False, (), error=error)
            payload = json.loads(stdout.splitlines()[-1])
            checks = tuple(
                VerificationCheck(status=str(item["status"]), message=str(item["message"]))
                for item in payload.get("checks", [])
            )
            return VerificationResult(
                passed=bool(payload.get("passed")),
                checks=checks,
                error=str(payload["error"]) if payload.get("error") else None,
            )

        if shell_verifier.exists():
            completed = subprocess.run(
                ["bash", str(shell_verifier)],
                capture_output=True,
                text=True,
                timeout=timeout,
                env=env,
                check=False,
            )
            return VerificationResult(
                passed=completed.returncode == 0,
                checks=parse_shell_verifier_output(completed.stdout),
                error=completed.stderr.strip() if completed.returncode != 0 and completed.stderr.strip() else None,
            )
    except subprocess.TimeoutExpired:
        return VerificationResult(False, (), error="Verification timed out")
    except json.JSONDecodeError as exc:
        return VerificationResult(False, (), error=f"Invalid verifier JSON output: {exc}")
    except Exception as exc:  # pragma: no cover - defensive runtime path
        return VerificationResult(False, (), error=str(exc))

    return VerificationResult(False, (), error=f"No verify.py or verify.sh for lab {lab_id}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m weaklink_platform.lab_runtime")
    parser.add_argument("lab_id")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--labs-root", default=str(DEFAULT_LABS_ROOT))
    parser.add_argument("--timeout", type=int, default=30)
    args = parser.parse_args(argv)
    result = execute_lab_verifier(
        args.lab_id,
        labs_root=Path(args.labs_root),
        timeout=args.timeout,
    )
    if args.json:
        print(json.dumps(result.to_payload()))
    else:
        print_verification_result(result)
    return 0 if result.passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
