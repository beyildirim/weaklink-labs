from __future__ import annotations

import shutil

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    scripts_dir = context.app_root / 'scripts'
    scripts_dir.mkdir(parents=True, exist_ok=True)
    source_scripts = context.lab_root / 'scripts'
    for item in source_scripts.iterdir():
        target = scripts_dir / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy2(item, target)
            if item.suffix in {'.sh', '.py'}:
                target.chmod(target.stat().st_mode | 0o111)
    for name in ('allowlist.txt', 'requirements.txt.secure'):
        source = context.lab_root / name
        if source.exists():
            shutil.copy2(source, context.app_root / name)
    return InitResult(
        workdir=context.default_workdir,
        env={'SECRET_API_KEY': 'sk-lab-7f3a9b2c4d5e6f1a8b9c0d1e2f3a4b5c'},
    )


if __name__ == '__main__':
    raise SystemExit(main_init(run))
