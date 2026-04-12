from __future__ import annotations

from pathlib import Path

import subprocess

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    log_path = Path('/tmp/0.1-lab-init.log')
    with log_path.open('w') as handle:
        subprocess.run(
            ['bash', str(context.lab_root / 'seed-repo.sh')],
            stdout=handle,
            stderr=subprocess.STDOUT,
            check=False,
        )
    return InitResult(workdir=context.default_workdir)


if __name__ == '__main__':
    raise SystemExit(main_init(run))
