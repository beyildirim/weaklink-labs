from __future__ import annotations

from shlex import quote

from weaklink_platform.lab_runtime import VerificationContext, main_verify, run_command_checks


def run(context: VerificationContext):
    requirements = quote(str(context.app_root / "requirements.yml"))
    roles_root = quote(str(context.app_root / "roles" / "ntp_config"))
    tasks_dir = quote(str(context.app_root / "roles" / "ntp_config" / "tasks"))
    playbook = quote(str(context.app_root / "playbooks" / "configure-servers.yml"))
    checks = (
        ("requirements.yml pins the reviewed ntp_config source", f"grep -q 'src: /app/vetted/ntp_config' {requirements}"),
        ("No SSH key injection in ntp role tasks", f"! grep -r 'authorized_keys' {tasks_dir}/"),
        ("No attacker SSH key in authorized_keys tasks", f"! grep -r 'AAAAB3NzaC1' {roles_root}/"),
        ("Playbook only contains NTP-related tasks", f"! grep -r -E '(authorized_keys|\\.ssh|id_rsa)' {playbook}"),
    )
    return run_command_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
