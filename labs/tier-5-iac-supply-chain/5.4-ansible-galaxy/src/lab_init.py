from __future__ import annotations

import shutil

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    vetted_root = context.app_root / "vetted"
    roles_root = context.app_root / "roles"
    vetted_root.mkdir(parents=True, exist_ok=True)
    roles_root.mkdir(parents=True, exist_ok=True)
    destination = vetted_root / "ntp_config"
    if destination.exists():
        shutil.rmtree(destination)
    shutil.copytree(context.lab_root / "vetted" / "ntp_config", destination)
    return InitResult(workdir=context.default_workdir)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
