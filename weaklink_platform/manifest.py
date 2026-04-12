from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

import yaml

from weaklink_platform.paths import GUIDE_LABS_ROOT, LABS_ROOT


PHASE_LABELS = {
    "phase_understand": ("UNDERSTAND", 1),
    "phase_break": ("BREAK", 2),
    "phase_defend": ("DEFEND", 3),
    "phase_detect": ("DETECT", 4),
    "phase_investigate": ("INVESTIGATE", 2),
    "phase_respond": ("RESPOND", 4),
}

ATTACK_PHASES = ("phase_understand", "phase_break", "phase_defend")
RESPONSE_PHASES = ("phase_understand", "phase_investigate", "phase_detect", "phase_respond")
ALLOWED_PHASE_COMBINATIONS = {ATTACK_PHASES, RESPONSE_PHASES}
KNOWN_KEYS = {
    "id",
    "title",
    "tier",
    "module",
    "prerequisites",
    "difficulty",
    "estimated_time",
    "tags",
    "mitre",
    *PHASE_LABELS,
}
ALLOWED_DIFFICULTIES = {"beginner", "intermediate", "advanced"}


class ManifestValidationError(ValueError):
    """Raised when a lab manifest is malformed."""


@dataclass(frozen=True)
class LabManifest:
    id: str
    title: str
    tier: int
    module: str
    prerequisites: tuple[str, ...]
    difficulty: str
    estimated_time: str
    tags: tuple[str, ...]
    phase_understand: str
    phase_break: str | None = None
    phase_defend: str | None = None
    phase_detect: str | None = None
    phase_investigate: str | None = None
    phase_respond: str | None = None
    mitre: tuple[str, ...] = field(default_factory=tuple)

    def phase_keys(self) -> tuple[str, ...]:
        keys: list[str] = []
        ordered_keys = sorted(PHASE_LABELS, key=lambda item: (PHASE_LABELS[item][1], item))
        for key in ordered_keys:
            if getattr(self, key):
                keys.append(key)
        return tuple(keys)

    def to_metadata(self) -> dict[str, object]:
        metadata: dict[str, object] = {
            "id": self.id,
            "title": self.title,
            "tier": self.tier,
            "module": self.module,
            "prerequisites": list(self.prerequisites),
            "difficulty": self.difficulty,
            "estimated_time": self.estimated_time,
            "tags": list(self.tags),
        }
        if self.mitre:
            metadata["mitre"] = list(self.mitre)
        for key in PHASE_LABELS:
            value = getattr(self, key)
            if value:
                metadata[key] = value
        return metadata


def _require_str(mapping: dict[str, object], key: str) -> str:
    value = mapping.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ManifestValidationError(f"{key} must be a non-empty string")
    return value


def _require_str_list(mapping: dict[str, object], key: str) -> tuple[str, ...]:
    value = mapping.get(key)
    if not isinstance(value, list) or any(not isinstance(item, str) for item in value):
        raise ManifestValidationError(f"{key} must be a list of strings")
    return tuple(value)


def _require_int(mapping: dict[str, object], key: str) -> int:
    value = mapping.get(key)
    if not isinstance(value, int):
        raise ManifestValidationError(f"{key} must be an integer")
    return value


def _optional_str(mapping: dict[str, object], key: str) -> str | None:
    value = mapping.get(key)
    if value is None:
        return None
    if not isinstance(value, str) or not value.strip():
        raise ManifestValidationError(f"{key} must be a non-empty string when present")
    return value


def load_lab_manifest(lab_dir: Path) -> LabManifest:
    manifest_path = lab_dir / "lab.yml"
    try:
        raw = yaml.safe_load(manifest_path.read_text())
    except yaml.YAMLError as exc:
        raise ManifestValidationError(f"invalid YAML: {exc}") from exc

    if not isinstance(raw, dict):
        raise ManifestValidationError("manifest root must be a mapping")

    unknown_keys = sorted(set(raw) - KNOWN_KEYS)
    if unknown_keys:
        raise ManifestValidationError(f"unknown keys: {', '.join(unknown_keys)}")

    manifest = LabManifest(
        id=_require_str(raw, "id"),
        title=_require_str(raw, "title"),
        tier=_require_int(raw, "tier"),
        module=_require_str(raw, "module"),
        prerequisites=_require_str_list(raw, "prerequisites"),
        difficulty=_require_str(raw, "difficulty"),
        estimated_time=_require_str(raw, "estimated_time"),
        tags=_require_str_list(raw, "tags"),
        mitre=_require_str_list(raw, "mitre") if "mitre" in raw else (),
        phase_understand=_require_str(raw, "phase_understand"),
        phase_break=_optional_str(raw, "phase_break"),
        phase_defend=_optional_str(raw, "phase_defend"),
        phase_detect=_optional_str(raw, "phase_detect"),
        phase_investigate=_optional_str(raw, "phase_investigate"),
        phase_respond=_optional_str(raw, "phase_respond"),
    )
    _validate_manifest(manifest, lab_dir)
    return manifest


def _validate_manifest(manifest: LabManifest, lab_dir: Path) -> None:
    if manifest.difficulty not in ALLOWED_DIFFICULTIES:
        raise ManifestValidationError(
            f"difficulty must be one of {', '.join(sorted(ALLOWED_DIFFICULTIES))}"
        )

    if manifest.id != lab_dir.name.split("-", 1)[0]:
        raise ManifestValidationError(
            f"id {manifest.id!r} does not match lab directory prefix {lab_dir.name!r}"
        )

    tier_dir = lab_dir.parent
    tier_parts = tier_dir.name.split("-", 2)
    if len(tier_parts) < 3 or tier_parts[0] != "tier":
        raise ManifestValidationError(f"unexpected tier directory name {tier_dir.name!r}")

    expected_tier = int(tier_parts[1])
    if manifest.tier != expected_tier:
        raise ManifestValidationError(
            f"tier {manifest.tier} does not match parent directory tier {expected_tier}"
        )

    parse_estimated_minutes(manifest.estimated_time)

    phase_keys = manifest.phase_keys()
    if phase_keys not in ALLOWED_PHASE_COMBINATIONS:
        allowed = ", ".join("+".join(combo) for combo in sorted(ALLOWED_PHASE_COMBINATIONS))
        raise ManifestValidationError(f"unsupported phase combination {phase_keys!r}; expected one of {allowed}")


def parse_estimated_minutes(time_value: str) -> int:
    minutes = 0
    remaining = time_value
    if "h" in remaining:
        hours, _, remaining = remaining.partition("h")
        if not hours.isdigit():
            raise ManifestValidationError(f"invalid estimated_time {time_value!r}")
        minutes += int(hours) * 60
    if "m" in remaining:
        mins, _, _ = remaining.partition("m")
        if not mins.isdigit():
            raise ManifestValidationError(f"invalid estimated_time {time_value!r}")
        minutes += int(mins)
    if minutes <= 0:
        raise ManifestValidationError(f"invalid estimated_time {time_value!r}")
    return minutes


def expected_guide_index(manifest: LabManifest, lab_dir: Path, guide_labs_root: Path = GUIDE_LABS_ROOT) -> Path:
    return guide_labs_root / f"tier-{manifest.tier}" / lab_dir.name / "index.md"


def lint_labs(
    labs_root: Path = LABS_ROOT,
    guide_labs_root: Path = GUIDE_LABS_ROOT,
) -> list[str]:
    errors: list[str] = []
    seen_ids: dict[str, Path] = {}

    for tier_dir in sorted(path for path in labs_root.glob("tier-*") if path.is_dir()):
        for lab_dir in sorted(path for path in tier_dir.iterdir() if path.is_dir()):
            manifest_path = lab_dir / "lab.yml"
            if not manifest_path.exists():
                continue
            try:
                manifest = load_lab_manifest(lab_dir)
            except ManifestValidationError as exc:
                errors.append(f"{lab_dir}: {exc}")
                continue

            existing = seen_ids.get(manifest.id)
            if existing is not None:
                errors.append(f"{lab_dir}: duplicate lab id {manifest.id!r} also used by {existing}")
            else:
                seen_ids[manifest.id] = lab_dir

            guide_index = expected_guide_index(manifest, lab_dir, guide_labs_root)
            if not guide_index.exists():
                errors.append(f"{lab_dir}: missing guide index at {guide_index}")

            if not (lab_dir / "verify.sh").exists() and not (lab_dir / "verify.py").exists():
                errors.append(f"{lab_dir}: missing verify.sh or verify.py")

            if not (lab_dir / "src").exists():
                errors.append(f"{lab_dir}: missing src/ directory")

    return errors
