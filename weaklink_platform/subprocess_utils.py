from __future__ import annotations

import os
import subprocess
from pathlib import Path
from typing import Iterable


def run(
    command: Iterable[str],
    *,
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
    capture_output: bool = False,
    check: bool = True,
    text: bool = True,
    input_text: str | None = None,
) -> subprocess.CompletedProcess[str]:
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    return subprocess.run(
        list(command),
        cwd=str(cwd) if cwd else None,
        env=merged_env,
        check=check,
        capture_output=capture_output,
        text=text,
        input=input_text,
    )


def capture(command: Iterable[str], *, cwd: Path | None = None, env: dict[str, str] | None = None) -> str:
    result = run(command, cwd=cwd, env=env, capture_output=True)
    return result.stdout.strip()
