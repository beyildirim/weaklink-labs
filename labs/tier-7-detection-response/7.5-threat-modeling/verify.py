from __future__ import annotations

import re
from pathlib import Path

from weaklink_platform.lab_runtime import VerificationContext, fail_check, main_verify, pass_check, result_from_checks


def _work_dir(context: VerificationContext) -> Path:
    return context.workdir if context.workdir != context.app_root else context.app_root / "work"


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
    chain_map = _matching(work_dir, "supply-chain-map.*")
    checks.append(
        pass_check("Supply chain map document exists")
        if chain_map
        else fail_check("Supply chain map document exists")
    )
    boundary_text = _text(_matching(work_dir, "supply-chain-map.*", "threat-model.*"))
    boundary_refs = len(re.findall(r"(trust.boundar|boundary|transition|handoff|cross.?cut)", boundary_text, re.IGNORECASE))
    checks.append(
        pass_check(f"Trust boundaries identified ({boundary_refs} references)")
        if boundary_refs >= 3
        else fail_check(f"Trust boundaries identified ({boundary_refs} references)")
    )
    stride_files = _matching(work_dir, "threat-model.*", "stride-analysis.*")
    stride_text = _text(stride_files)
    stride_count = sum(
        1
        for element in (
            r"spoof",
            r"tamper",
            r"repudiat",
            r"disclosure|information.leak",
            r"denial.of.service|dos",
            r"elevation|privilege.escalat",
        )
        if re.search(element, stride_text, re.IGNORECASE)
    )
    checks.append(
        pass_check(f"STRIDE analysis covers {stride_count}/6 threat categories")
        if stride_files and stride_count >= 4
        else fail_check(f"STRIDE analysis covers {stride_count}/6 threat categories")
    )
    risk_text = _text(_matching(work_dir, "threat-model.*", "stride-analysis.*", "risk-register.*"))
    prioritization = bool(
        re.search(r"(likelihood|probability|impact|risk.score|risk.rating|high|medium|low|critical)", risk_text, re.IGNORECASE)
    )
    checks.append(
        pass_check("Risk prioritization with likelihood/impact assessment present")
        if prioritization
        else fail_check("Risk prioritization with likelihood/impact assessment present")
    )
    gap_files = _matching(work_dir, "gap-analysis.*", "risk-register.*")
    gap_text = _text(gap_files)
    control_refs = len(re.findall(r"(control|mitigation|countermeasure|defense|gap|residual|existing|missing)", gap_text, re.IGNORECASE))
    checks.append(
        pass_check(f"Gap analysis maps threats to controls ({control_refs} references)")
        if gap_files and control_refs >= 3
        else fail_check(f"Gap analysis maps threats to controls ({control_refs} references)")
    )
    return result_from_checks(checks)


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
