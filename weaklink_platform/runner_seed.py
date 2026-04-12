from __future__ import annotations

import shutil
from pathlib import Path


def create_simulated_runner(runner_dir: Path = Path("/runner")) -> None:
    if runner_dir.exists():
        for child in runner_dir.iterdir():
            if child.is_dir():
                shutil.rmtree(child)
            else:
                child.unlink()
    runner_dir.mkdir(parents=True, exist_ok=True)

    workspace = runner_dir / "workspace"
    hooks = runner_dir / "hooks"
    config = runner_dir / "config"
    for path in (workspace, hooks, config):
        path.mkdir(parents=True, exist_ok=True)

    (workspace / ".bashrc").write_text(
        "# Runner profile -- sourced before each job\n"
        'export RUNNER_NAME="wl-runner-01"\n'
        'export RUNNER_OS="Linux"\n'
    )

    run_job = runner_dir / "run-job.sh"
    run_job.write_text(
        "#!/bin/bash\n"
        "# Simulated job executor\n"
        'echo "[runner] Starting job on $(hostname)..."\n'
        'echo "[runner] Sourcing workspace profile..."\n'
        "source /runner/workspace/.bashrc\n"
        'echo "[runner] Running pre-job hooks..."\n'
        "for hook in /runner/hooks/pre-job*.sh; do\n"
        '    [ -f "$hook" ] && bash "$hook"\n'
        "done\n"
        'echo "[runner] Executing job steps..."\n'
        "cd /runner/workspace\n"
        '"$@"\n'
        'echo "[runner] Job complete."\n'
    )
    run_job.chmod(0o755)
