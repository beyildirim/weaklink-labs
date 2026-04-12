from __future__ import annotations

import time

from weaklink_platform.lab_runtime import InitContext, InitResult, http_ok, main_init, run_command


def run(context: InitContext) -> InitResult:
    registry = "registry:5000"
    for _ in range(30):
        if http_ok(f"http://{registry}/v2/"):
            break
        time.sleep(1)

    run_command(["crane", "--insecure", "copy", f"{registry}/webapp:1.0.0", f"{registry}/webapp:latest"])
    digest = run_command(["crane", "--insecure", "digest", f"{registry}/webapp:1.0.0"]).stdout.strip()
    (context.workspace_root / "safe-digest.txt").write_text(digest + "\n")
    (context.lab_src_link.parent / "safe-digest.txt").write_text(digest + "\n")
    return InitResult(workdir=context.workspace_root)


if __name__ == "__main__":
    raise SystemExit(main_init(run))
