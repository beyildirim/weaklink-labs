from __future__ import annotations

import shutil
import subprocess

from weaklink_platform.lab_runtime import InitContext, InitResult, main_init


def run(context: InitContext) -> InitResult:
    workspace = context.workspace_root / "artifact-demo"
    reference_dir = workspace / "reference"
    source_dir = context.lab_root / "packages" / "demo-lib"

    if workspace.exists():
        shutil.rmtree(workspace)
    reference_dir.mkdir(parents=True, exist_ok=True)

    build_dir = source_dir / "dist"
    for path in (source_dir / "build", build_dir):
        if path.exists():
            shutil.rmtree(path)
    for path in source_dir.glob("*.egg-info"):
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()

    with open("/tmp/0.5-build.log", "w") as build_log:
        subprocess.run(
            ["python", "setup.py", "sdist"],
            cwd=str(source_dir),
            stdout=build_log,
            stderr=subprocess.STDOUT,
            check=False,
        )

    tarballs = sorted(build_dir.glob("demo_lib-*.tar.gz"))
    if tarballs:
        shutil.copy2(tarballs[0], reference_dir / tarballs[0].name)

    (workspace / "requirements.txt").write_text("demo-lib==1.0.0\n")
    (workspace / "hash-check.log").touch()

    subprocess.run(["pip", "install", "--quiet", "twine"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    with open("/tmp/0.5-upload.log", "w") as upload_log:
        subprocess.run(
            ["twine", "upload", "--skip-existing", "--repository-url", "http://pypi-private:8080/", *[str(path) for path in build_dir.glob("*")]],
            stdout=upload_log,
            stderr=subprocess.STDOUT,
            check=False,
        )

    return InitResult(workdir=workspace)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
