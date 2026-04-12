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


def _count(pattern: str, files: list[Path]) -> int:
    regex = re.compile(pattern, re.IGNORECASE)
    total = 0
    for path in files:
        if path.exists():
            total += len(regex.findall(path.read_text()))
    return total


def run(context: VerificationContext):
    work_dir = _work_dir(context)
    checks = []
    investigation = _matching(work_dir, "investigation.*")
    scope_refs = _count(r"(pipeline|ci.run|build.job|runner|github.actions|gitlab)", investigation)
    checks.append(
        pass_check(f"Investigation notes contain scope analysis ({scope_refs} pipeline references)")
        if investigation and scope_refs >= 2
        else fail_check(f"Investigation notes contain scope analysis ({scope_refs} pipeline references)")
    )
    blast = _matching(work_dir, "blast-radius.*")
    secret_refs = _count(r"(secret|token|credential|api.key|aws|gcp|azure|npm_token|pypi_token|docker)", blast)
    checks.append(
        pass_check(f"Blast radius analysis identifies exposed secrets ({secret_refs} references)")
        if blast and secret_refs >= 2
        else fail_check(f"Blast radius analysis identifies exposed secrets ({secret_refs} references)")
    )
    severity_files = _matching(work_dir, "investigation.*", "incident-summary.*")
    severity_text = "\n".join(path.read_text() for path in severity_files if path.exists())
    severity_ok = bool(
        re.search(r"(critical|high|severe|p1|sev.?1|sev.?2)", severity_text, re.IGNORECASE)
        and re.search(r"(severity|classification|priority)", severity_text, re.IGNORECASE)
    )
    checks.append(
        pass_check("Severity classification found in investigation or incident summary")
        if severity_ok
        else fail_check("Severity classification found in investigation or incident summary")
    )
    summary = _matching(work_dir, "incident-summary.*")
    action_refs = _count(r"(rotate|revoke|quarantine|block|disable|remediat|contain|isolat)", summary)
    checks.append(
        pass_check(f"Incident summary includes remediation actions ({action_refs} action items)")
        if summary and action_refs >= 2
        else fail_check(f"Incident summary includes remediation actions ({action_refs} action items)")
    )
    timeline_refs = _count(r"([0-9]{2}:[0-9]{2}|hour|minute|T-[0-9]|timeline|timestamp|utc|ago)", severity_files)
    checks.append(
        pass_check(f"Timeline reconstruction present ({timeline_refs} time references)")
        if timeline_refs >= 2
        else fail_check(f"Timeline reconstruction present ({timeline_refs} time references)")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
