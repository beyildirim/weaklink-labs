from __future__ import annotations

import re
from pathlib import Path

from weaklink_platform.lab_runtime import VerificationContext, fail_check, main_verify, pass_check, result_from_checks


def _work_dir(context: VerificationContext) -> Path:
    return context.workdir if context.workdir != context.app_root else context.lab_root / "work"


def _matching(work_dir: Path, *patterns: str) -> list[Path]:
    found: list[Path] = []
    for pattern in patterns:
        found.extend(sorted(work_dir.glob(pattern)))
    return found


def _text(files: list[Path]) -> str:
    return "\n".join(path.read_text() for path in files if path.exists())


def run(context: VerificationContext):
    work_dir = _work_dir(context)
    checks = []
    playbook = _matching(work_dir, "ir-playbook.*")
    checks.append(
        pass_check("IR playbook document exists")
        if playbook
        else fail_check("IR playbook document exists")
    )
    playbook_text = _text(playbook)
    phases = sum(
        1
        for phase in ("preparation", "detection", "containment", "eradication", "recovery", "lessons")
        if re.search(phase, playbook_text, re.IGNORECASE)
    )
    checks.append(
        pass_check(f"Playbook covers {phases}/6 NIST SP 800-61 phases")
        if phases >= 5
        else fail_check(f"Playbook covers {phases}/6 NIST SP 800-61 phases")
    )
    decision_ok = bool(
        re.search(r"(decision.tree|escalat|if.*then|flowchart|criteria|threshold|sev.?[0-9]|p[0-9])", playbook_text, re.IGNORECASE)
    )
    checks.append(
        pass_check("Decision tree or escalation criteria present")
        if decision_ok
        else fail_check("Decision tree or escalation criteria present")
    )
    validation = _matching(work_dir, "walkthrough.*", "validation.*")
    validation_text = _text(validation)
    validated = bool(re.search(r"(internal.utils|99\.0\.0|lab.7\.2|dependency.confusion)", validation_text, re.IGNORECASE))
    checks.append(
        pass_check("Playbook validated against Lab 7.2 scenario")
        if validation and validated
        else fail_check("Playbook validated against Lab 7.2 scenario")
    )
    post_incident = _matching(work_dir, "post-incident*.md", "pir-template.md")
    post_text = _text(post_incident)
    sections = sum(
        1
        for keyword in (r"root.cause", r"timeline", r"impact", r"action.items|remediation|follow.up")
        if re.search(keyword, post_text, re.IGNORECASE)
    )
    checks.append(
        pass_check(f"Post-incident report template covers {sections}/4 required sections")
        if post_incident and sections >= 3
        else fail_check(f"Post-incident report template covers {sections}/4 required sections")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
