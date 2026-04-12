from __future__ import annotations

import shutil

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    project = context.app_root / 'project'
    project.mkdir(parents=True, exist_ok=True)
    scripts = context.lab_root / 'scripts'
    for name in ('requirements.in', 'verify-lockfile.sh', 'app.py'):
        source = scripts / name
        if source.exists():
            target = project / name
            shutil.copy2(source, target)
            if target.suffix == '.sh':
                target.chmod(target.stat().st_mode | 0o111)
    return InitResult(workdir=context.default_workdir)


if __name__ == '__main__':
    raise SystemExit(main_init(run))
