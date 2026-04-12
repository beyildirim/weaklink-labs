from __future__ import annotations

from pathlib import Path

import shutil

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    pip_configs = Path('/etc/pip-configs')
    pip_configs.mkdir(parents=True, exist_ok=True)
    shutil.copy2(context.lab_root / 'pip.conf.vulnerable', pip_configs / 'pip.conf.vulnerable')
    shutil.copy2(context.lab_root / 'pip.conf.safe', pip_configs / 'pip.conf.safe')
    shutil.copy2(pip_configs / 'pip.conf.vulnerable', Path('/etc/pip.conf'))
    scripts_dir = context.lab_root / 'scripts'
    if scripts_dir.exists():
        for pattern in ('*.sh', '*.py'):
            for script in scripts_dir.glob(pattern):
                script.chmod(script.stat().st_mode | 0o111)
    target = context.app_root / 'scripts'
    target.unlink(missing_ok=True)
    if target.exists() and target.is_dir():
        shutil.rmtree(target)
    target.symlink_to(scripts_dir, target_is_directory=True)
    Path('/tmp/dependency-confusion-pwned').unlink(missing_ok=True)
    return InitResult(workdir=context.default_workdir)


if __name__ == '__main__':
    raise SystemExit(main_init(run))
