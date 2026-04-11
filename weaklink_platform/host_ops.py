from __future__ import annotations

import json
import os
import shutil
import shlex
import signal
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable
from urllib.request import urlopen

from weaklink_platform.console import Style, dim, error, header, info, ok, warn
from weaklink_platform.labs import count_lab_inventory, iter_labs
from weaklink_platform.paths import HOST_PORT_FORWARD_DIR, REPO_ROOT, ensure_host_state_dir
from weaklink_platform.subprocess_utils import capture, run


NAMESPACE = "weaklink"
HELM_RELEASE = "weaklink-labs"
HELM_CHART = REPO_ROOT / "helm" / "weaklink-labs"


@dataclass(frozen=True)
class ImageSpec:
    name: str
    dockerfile: Path
    context: Path
    tag: str


@dataclass(frozen=True)
class PortForwardSpec:
    name: str
    service: str
    local_port: int
    remote_port: int
    healthcheck: str | None


IMAGE_SPECS = {
    "guide": ImageSpec(
        name="guide",
        dockerfile=REPO_ROOT / "images" / "guide" / "Dockerfile",
        context=REPO_ROOT / "guide",
        tag="weaklink-labs/guide:latest",
    ),
    "workstation": ImageSpec(
        name="workstation",
        dockerfile=REPO_ROOT / "images" / "workstation" / "Dockerfile",
        context=REPO_ROOT,
        tag="weaklink-labs/workstation:latest",
    ),
    "lab-setup": ImageSpec(
        name="lab-setup",
        dockerfile=REPO_ROOT / "images" / "lab-setup" / "Dockerfile",
        context=REPO_ROOT,
        tag="weaklink-labs/lab-setup:latest",
    ),
}

PORT_FORWARDS = (
    PortForwardSpec("guide", "guide", 8000, 8000, "http://localhost:8000"),
    PortForwardSpec("web terminal", "workstation", 7681, 7681, "http://localhost:7681"),
    PortForwardSpec("verify API", "workstation", 7682, 7682, "http://localhost:7682/healthz"),
    PortForwardSpec("Gitea", "gitea", 3000, 3000, "http://localhost:3000"),
)

READY_DEPLOYMENTS = ("pypi-private", "pypi-public", "verdaccio", "gitea", "registry", "guide", "workstation")


def parse_minikube_docker_env(payload: str) -> dict[str, str]:
    payload = payload.strip()
    if not payload:
        return {}

    try:
        parsed = json.loads(payload)
    except json.JSONDecodeError:
        parsed = None

    if parsed is not None:
        if isinstance(parsed, dict) and all(isinstance(value, str) for value in parsed.values()):
            return {key: value for key, value in parsed.items()}
        if isinstance(parsed, dict):
            for key in ("docker-env", "environment", "env"):
                if key in parsed:
                    env = parsed[key]
                    if isinstance(env, dict):
                        return {name: str(value) for name, value in env.items()}
                    if isinstance(env, list):
                        result: dict[str, str] = {}
                        for item in env:
                            if isinstance(item, dict) and "name" in item and "value" in item:
                                result[str(item["name"])] = str(item["value"])
                        if result:
                            return result
        raise ValueError("Unsupported minikube docker-env JSON payload")

    result: dict[str, str] = {}
    for raw_line in payload.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line.removeprefix("export ").strip()
        elif line.lower().startswith("set "):
            line = line[4:].strip()
        elif line.startswith("$Env:"):
            name, separator, value = line[5:].partition("=")
            if separator:
                result[name.strip()] = shlex.split(value.strip())[0] if value.strip() else ""
            continue
        elif line.startswith("unset "):
            continue

        if "=" not in line:
            continue

        name, value = line.split("=", 1)
        name = name.strip()
        value = value.strip().rstrip(";")
        if not name:
            continue
        if value:
            parsed_value = shlex.split(value)
            result[name] = parsed_value[0] if parsed_value else ""
        else:
            result[name] = ""

    if result:
        return result

    raise ValueError("Unsupported minikube docker-env payload")


def _minikube_docker_env() -> dict[str, str]:
    payload = capture(["minikube", "docker-env", "-o", "json"])
    return parse_minikube_docker_env(payload)


def _http_ready(url: str) -> bool:
    try:
        with urlopen(url, timeout=2):
            return True
    except OSError:
        return False


def wait_for_http(name: str, url: str, *, attempts: int = 30) -> None:
    for _ in range(attempts):
        if _http_ready(url):
            ok(f"{name} is reachable at {url}.")
            return
        time.sleep(1)
    raise RuntimeError(f"{name} did not become reachable at {url}.")


def require_commands(commands: Iterable[str]) -> None:
    missing = [command for command in commands if shutil.which(command) is None]
    if not missing:
        return
    for command in missing:
        error(f"{command} not found")
    raise RuntimeError(f"Missing prerequisites: {' '.join(missing)}")


def ensure_minikube_running() -> None:
    status = "Stopped"
    try:
        status = capture(["minikube", "status", "--format={{.Host}}"])
    except subprocess.CalledProcessError:
        status = "Stopped"
    if status == "Running":
        ok("minikube is already running.")
        return
    info("Starting minikube with 4 CPUs and 4GB memory...")
    run(["minikube", "start", "--cpus=4", "--memory=4096", "--driver=docker"])
    ok("minikube started.")


def build_images(targets: list[str] | None = None) -> None:
    targets = targets or list(IMAGE_SPECS)
    docker_env = _minikube_docker_env()
    for target in targets:
        spec = IMAGE_SPECS[target]
        header(f"Building {target}...")
        run(
            [
                "docker",
                "build",
                "-t",
                spec.tag,
                "-f",
                str(spec.dockerfile),
                str(spec.context),
            ],
            env=docker_env,
        )


def deploy_release() -> None:
    header("Deploying to Kubernetes...")
    run(
        [
            "helm",
            "upgrade",
            "--install",
            HELM_RELEASE,
            str(HELM_CHART),
            "-n",
            NAMESPACE,
            "--create-namespace",
            "--wait",
            "--timeout",
            "5m",
        ]
    )
    ok("Helm release deployed.")


def wait_for_deployments() -> None:
    header("Waiting for pods to be ready...")
    for deployment in READY_DEPLOYMENTS:
        info(f"Waiting for {deployment}...")
        result = run(
            [
                "kubectl",
                "wait",
                "--for=condition=available",
                f"deployment/{deployment}",
                "-n",
                NAMESPACE,
                "--timeout=120s",
            ],
            check=False,
            capture_output=True,
        )
        if result.returncode == 0:
            ok(f"{deployment} is ready.")
        else:
            warn(f"{deployment} may not be ready yet.")


def wait_for_lab_setup_job() -> None:
    info("Waiting for lab-setup job to complete...")
    time.sleep(5)
    exists = run(["kubectl", "get", "job", "lab-setup", "-n", NAMESPACE], check=False).returncode == 0
    if not exists:
        warn("Lab setup job not found yet. It will run shortly.")
        return
    result = run(
        [
            "kubectl",
            "wait",
            "--for=condition=complete",
            "job/lab-setup",
            "-n",
            NAMESPACE,
            "--timeout=300s",
        ],
        check=False,
        capture_output=True,
    )
    if result.returncode == 0:
        ok("Lab setup complete.")
    else:
        warn(f"Lab setup still running. Check logs: kubectl logs -n {NAMESPACE} job/lab-setup")


def _pid_file(spec: PortForwardSpec) -> Path:
    ensure_host_state_dir()
    return HOST_PORT_FORWARD_DIR / f"{spec.service}-{spec.local_port}.pid"


def _log_file(spec: PortForwardSpec) -> Path:
    ensure_host_state_dir()
    safe_name = spec.name.lower().replace(" ", "-")
    return HOST_PORT_FORWARD_DIR / f"{safe_name}.log"


def _stop_pid(pid: int) -> None:
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    for _ in range(10):
        try:
            os.kill(pid, 0)
        except ProcessLookupError:
            return
        time.sleep(0.2)
    try:
        os.kill(pid, signal.SIGKILL)
    except ProcessLookupError:
        return


def stop_port_forwards() -> None:
    ensure_host_state_dir()
    for spec in PORT_FORWARDS:
        pid_file = _pid_file(spec)
        if not pid_file.exists():
            continue
        try:
            pid = int(pid_file.read_text().strip())
        except ValueError:
            pid_file.unlink(missing_ok=True)
            continue
        _stop_pid(pid)
        pid_file.unlink(missing_ok=True)
        ok(f"{spec.name} port-forward stopped.")


def start_port_forwards() -> None:
    stop_port_forwards()
    for spec in PORT_FORWARDS:
        info(f"Starting port-forward for {spec.name} (localhost:{spec.local_port})...")
        log_file = _log_file(spec)
        process = subprocess.Popen(
            [
                "kubectl",
                "port-forward",
                "-n",
                NAMESPACE,
                f"svc/{spec.service}",
                f"{spec.local_port}:{spec.remote_port}",
            ],
            stdout=log_file.open("w"),
            stderr=subprocess.STDOUT,
            text=True,
        )
        _pid_file(spec).write_text(str(process.pid))
        forwarded = False
        for _ in range(15):
            if process.poll() is not None:
                raise RuntimeError(f"{spec.name} port-forward exited early. Check {log_file}.")
            contents = log_file.read_text() if log_file.exists() else ""
            if f"Forwarding from 127.0.0.1:{spec.local_port}" in contents or f"Forwarding from [::1]:{spec.local_port}" in contents:
                forwarded = True
                break
            time.sleep(1)
        if not forwarded:
            raise RuntimeError(f"{spec.name} port-forward did not become ready. Check {log_file}.")
        if spec.healthcheck:
            wait_for_http(spec.name, spec.healthcheck)


def start_platform() -> None:
    current_step = "prerequisites"
    try:
        header("Checking prerequisites...")
        require_commands(["docker", "minikube", "kubectl", "helm"])
        for command in ("docker", "minikube", "kubectl", "helm"):
            ok(f"{command} found: {shutil.which(command)}")

        current_step = "minikube"
        header("Starting minikube...")
        ensure_minikube_running()

        current_step = "docker-build"
        header("Building Docker images...")
        build_images()

        current_step = "helm-deploy"
        deploy_release()

        current_step = "pod-readiness"
        wait_for_deployments()

        current_step = "lab-setup"
        wait_for_lab_setup_job()

        current_step = "port-forward"
        start_port_forwards()

        print()
        print(f"{Style.BOLD}========================================{Style.NC}")
        print(f"{Style.GREEN}{Style.BOLD}  WeakLink Labs is ready!{Style.NC}")
        print(f"{Style.BOLD}========================================{Style.NC}")
        print()
    except Exception as exc:
        error(f"Setup failed at step: {current_step}")
        error(str(exc))
        print()
        print(f"  {dim('Debug commands:')}")
        print(f"    kubectl get pods -n {NAMESPACE}")
        print(f"    kubectl describe pods -n {NAMESPACE}")
        print(f"    kubectl logs -n {NAMESPACE} job/lab-setup")
        print()
        print(f"  {dim('To retry: make start')}")
        print(f"  {dim('To tear down: make stop')}")
        raise


def stop_platform() -> None:
    print()
    print(f"{Style.BOLD}WeakLink Labs -- Teardown{Style.NC}")
    print()
    stop_port_forwards()
    info("Uninstalling Helm release...")
    release_list = run(["helm", "list", "-n", NAMESPACE, "-o", "json"], capture_output=True, check=False)
    if release_list.returncode == 0 and HELM_RELEASE in release_list.stdout:
        run(["helm", "uninstall", HELM_RELEASE, "-n", NAMESPACE], check=False)
        ok("Helm release uninstalled.")
    else:
        warn(f"No Helm release found in {NAMESPACE} namespace.")
    info(f"Deleting {NAMESPACE} namespace...")
    run(["kubectl", "delete", "namespace", NAMESPACE, "--ignore-not-found"], check=False)
    ok("Namespace deleted.")
    ok("minikube left running.")
    print()
    ok("WeakLink Labs torn down.")
    print()


def clean_platform() -> None:
    stop_platform()
    run(["minikube", "delete"], check=False)
    ok("Cluster deleted.")


def show_status() -> None:
    run(["kubectl", "get", "pods", "-n", NAMESPACE, "-o", "wide"])


def _pod_names() -> list[str]:
    result = capture(["kubectl", "get", "pods", "-n", NAMESPACE, "-o", "jsonpath={.items[*].metadata.name}"])
    return [name for name in result.split() if name]


def show_logs() -> None:
    for pod in _pod_names():
        print()
        print(f"--- {pod} ---")
        run(["kubectl", "logs", pod, "-n", NAMESPACE, "--all-containers", "--tail=20"], check=False)


def build_docs(site_url: str = "") -> None:
    local_venv = REPO_ROOT / ".venv" / "bin" / "mkdocs"
    env = {"SITE_URL": site_url}
    if local_venv.exists():
        command = [str(local_venv), "build", "--strict", "-f", "guide/mkdocs.yml"]
    elif shutil.which("mkdocs"):
        command = ["mkdocs", "build", "--strict", "-f", "guide/mkdocs.yml"]
    else:
        command = [
            "docker",
            "run",
            "--rm",
            "-e",
            f"SITE_URL={site_url}",
            "-v",
            f"{REPO_ROOT}:/workspace",
            "-w",
            "/workspace",
            "squidfunk/mkdocs-material:latest",
            "build",
            "--strict",
            "-f",
            "guide/mkdocs.yml",
        ]
        env = None
    result = run(command, cwd=REPO_ROOT, env=env, capture_output=True, check=False)
    if result.stdout:
        print(result.stdout, end="" if result.stdout.endswith("\n") else "\n")
    if result.stderr:
        print(result.stderr, end="" if result.stderr.endswith("\n") else "\n")
    if result.returncode != 0:
        raise RuntimeError("MkDocs build failed.")
    combined = f"{result.stdout}\n{result.stderr}"
    if "unrecognized relative link" in combined:
        raise RuntimeError("MkDocs reported unrecognized relative links.")


def _select_workstation_pod(namespace: str, selector: str) -> str:
    run(
        [
            "kubectl",
            "wait",
            "pod",
            "--namespace",
            namespace,
            "-l",
            selector,
            "--for=condition=Ready",
            "--timeout=180s",
        ]
    )
    pod = capture(
        [
            "kubectl",
            "get",
            "pod",
            "--namespace",
            namespace,
            "-l",
            selector,
            "--field-selector=status.phase=Running",
            "--sort-by=.metadata.creationTimestamp",
            "-o",
            "jsonpath={range .items[*]}{.metadata.name}{'\\n'}{end}",
        ]
    )
    names = [line for line in pod.splitlines() if line]
    if not names:
        raise RuntimeError(f"No workstation pod found in namespace {namespace}.")
    return names[-1]


def smoke_test(namespace: str = NAMESPACE, workstation_selector: str = "app.kubernetes.io/name=workstation") -> None:
    workstation_pod = _select_workstation_pod(namespace, workstation_selector)
    print(f"Using workstation pod: {workstation_pod}")

    lab_count, verify_count, guide_count = count_lab_inventory()
    print(
        f"Content inventory: {lab_count} lab manifests, {verify_count} verify scripts, {guide_count} guide index pages"
    )
    if lab_count != verify_count or lab_count != guide_count:
        raise RuntimeError("Lab content counts do not match.")

    failed = 0
    passed = 0
    for lab in iter_labs():
        print()
        print("========================================")
        print(f"  Smoke testing: {lab.lab_dir.name}")
        print("========================================")
        script = f"""
set -euo pipefail
lab-init '{lab.lab_id}' >/tmp/lab-init-{lab.lab_id}.log 2>&1
test "$(cat /tmp/.weaklink-current-lab)" = '{lab.lab_id}'
workdir=$(cat /tmp/.weaklink-workdir)
test -n "$workdir"
test -d "$workdir"
test -d '/home/labs/{lab.lab_id}'
test -d /app
test -f '/home/labs/{lab.lab_id}/verify.sh'
bash -n '/home/labs/{lab.lab_id}/verify.sh'
"""
        result = run(
            ["kubectl", "exec", workstation_pod, "--namespace", namespace, "--", "bash", "-lc", script],
            check=False,
        )
        if result.returncode == 0:
            print(f"  >>> {lab.lab_dir.name}: PASSED (initialized cleanly)")
            passed += 1
            continue
        print("  --- lab-init log ---")
        run(
            [
                "kubectl",
                "exec",
                workstation_pod,
                "--namespace",
                namespace,
                "--",
                "bash",
                "-lc",
                f"cat /tmp/lab-init-{lab.lab_id}.log 2>/dev/null || true",
            ],
            check=False,
        )
        print(f"  >>> {lab.lab_dir.name}: FAILED")
        failed += 1

    print()
    print("========================================")
    print(f"  Lab Smoke Test Summary: {passed} passed, {failed} failed")
    print("========================================")
    if failed:
        raise RuntimeError(f"{failed} lab(s) failed smoke testing.")


def clean_images() -> None:
    docker_env = _minikube_docker_env()
    image_ids = capture(["docker", "images", "--filter=reference=weaklink-labs/*", "-q"], env=docker_env)
    ids = [image_id for image_id in image_ids.splitlines() if image_id]
    if ids:
        run(["docker", "rmi", "-f", *ids], env=docker_env)
    ok("Images cleaned.")


def sign_images(*, keyless: bool) -> None:
    if shutil.which("cosign") is None:
        raise RuntimeError("cosign not found.")
    key_dir = REPO_ROOT / ".cosign"
    key_path = key_dir / "cosign.key"
    public_key = key_dir / "cosign.pub"
    if not keyless and not key_path.exists():
        info(f"Generating Cosign key pair in {key_dir}...")
        key_dir.mkdir(parents=True, exist_ok=True)
        env = os.environ.copy()
        env["COSIGN_PASSWORD"] = ""
        subprocess.run(
            ["cosign", "generate-key-pair", f"--output-key-prefix={key_dir / 'cosign'}"],
            check=True,
            env=env,
        )
        ok("Key pair generated.")
        print(f"  {dim(f'Public key:  {public_key}')}")
        print(f"  {dim(f'Private key: {key_path} (keep this safe!)')}")

    images = [spec.tag for spec in IMAGE_SPECS.values()]
    print()
    print(f"{Style.BOLD}Signing WeakLink Labs Docker images...{Style.NC}")
    print()
    signed = 0
    failed = 0
    for image in images:
        info(f"Signing {image}...")
        env = os.environ.copy()
        if keyless:
            command = ["cosign", "sign", "--yes", image]
        else:
            env["COSIGN_PASSWORD"] = ""
            command = ["cosign", "sign", "--key", str(key_path), image]
        result = subprocess.run(command, check=False, env=env)
        if result.returncode == 0:
            ok(f"{image} signed")
            signed += 1
        else:
            error(f"Failed to sign {image}")
            failed += 1
    print()
    print(f"{Style.BOLD}=== Signing Summary ==={Style.NC}")
    print(f"  Signed: {signed}")
    print(f"  Failed: {failed}")
    if not keyless:
        print()
        print(f"{Style.BOLD}Verify with:{Style.NC}")
        print(f"  {dim(f'cosign verify --key {public_key} <image>')}")
    if failed:
        raise RuntimeError(f"{failed} image(s) failed signing.")
