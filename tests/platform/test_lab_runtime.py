from __future__ import annotations

from pathlib import Path

from weaklink_platform.lab_runtime import execute_lab_verifier
from weaklink_platform.manifest import lint_labs, load_lab_manifest


def test_execute_lab_verifier_prefers_python_verifier(tmp_path: Path) -> None:
    lab_dir = tmp_path / "9.9"
    lab_dir.mkdir()
    (lab_dir / "verify.py").write_text(
        """
from weaklink_platform.lab_runtime import VerificationCheck, VerificationContext, VerificationResult, main_verify


def run(context: VerificationContext) -> VerificationResult:
    return VerificationResult(True, (VerificationCheck("pass", f"verified {context.lab_id}"),))


if __name__ == "__main__":
    raise SystemExit(main_verify(run))
"""
    )
    (lab_dir / "verify.sh").write_text("#!/bin/bash\nexit 1\n")

    result = execute_lab_verifier("9.9", lab_dir=lab_dir)

    assert result.passed is True
    assert result.checks[0].message == "verified 9.9"


def test_load_lab_manifest_supports_response_phase_shape() -> None:
    manifest = load_lab_manifest(
        Path("labs/tier-7-detection-response/7.5-threat-modeling")
    )

    assert manifest.phase_keys() == (
        "phase_understand",
        "phase_investigate",
        "phase_detect",
        "phase_respond",
    )


def test_lint_labs_accepts_python_verifier(tmp_path: Path) -> None:
    labs_root = tmp_path / "labs"
    guide_root = tmp_path / "guide"
    lab_dir = labs_root / "tier-1-package-security" / "1.9-python-verifier"
    lab_dir.mkdir(parents=True)
    (lab_dir / "src").mkdir()
    (lab_dir / "verify.py").write_text("print('ok')\n")
    (lab_dir / "lab.yml").write_text(
        """id: "1.9"
title: "Python Verifier"
tier: 1
module: "package-security"
prerequisites: []
difficulty: beginner
estimated_time: 20m
tags: ["python"]
phase_understand: "Read the system"
phase_break: "Break the system"
phase_defend: "Defend the system"
"""
    )
    guide_index = guide_root / "tier-1" / "1.9-python-verifier" / "index.md"
    guide_index.parent.mkdir(parents=True)
    guide_index.write_text("# Python Verifier\n")

    assert lint_labs(labs_root=labs_root, guide_labs_root=guide_root) == []
