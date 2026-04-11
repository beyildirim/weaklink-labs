from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from weaklink_platform.paths import GUIDE_LABS_ROOT, LABS_ROOT
from weaklink_platform.yamlish import parse_simple_yaml


PHASE_LABELS = {
    "phase_understand": ("UNDERSTAND", 1),
    "phase_break": ("BREAK", 2),
    "phase_defend": ("DEFEND", 3),
    "phase_detect": ("DETECT", 4),
    "phase_investigate": ("INVESTIGATE", 2),
    "phase_respond": ("RESPOND", 4),
}


@dataclass(frozen=True)
class Lab:
    lab_id: str
    title: str
    tier: int
    tier_name: str
    lab_dir: Path
    metadata: dict[str, object]


def _tier_name_from_dir(tier_dir: Path) -> str:
    parts = tier_dir.name.split("-", 2)
    suffix = parts[2] if len(parts) > 2 else tier_dir.name
    return " ".join(part.capitalize() for part in suffix.split("-"))


def load_lab_metadata(lab_dir: Path) -> dict[str, object]:
    return parse_simple_yaml((lab_dir / "lab.yml").read_text())


def iter_labs(labs_root: Path = LABS_ROOT) -> list[Lab]:
    labs: list[Lab] = []
    for tier_dir in sorted(p for p in labs_root.glob("tier-*") if p.is_dir()):
        tier_name = _tier_name_from_dir(tier_dir)
        tier_num = int(tier_dir.name.split("-", 2)[1])
        for lab_dir in sorted(p for p in tier_dir.iterdir() if p.is_dir()):
            manifest = lab_dir / "lab.yml"
            if not manifest.exists():
                continue
            metadata = load_lab_metadata(lab_dir)
            labs.append(
                Lab(
                    lab_id=str(metadata["id"]),
                    title=str(metadata["title"]),
                    tier=tier_num,
                    tier_name=tier_name,
                    lab_dir=lab_dir,
                    metadata=metadata,
                )
            )
    return labs


def find_lab(lab_id: str, labs_root: Path = LABS_ROOT) -> Lab | None:
    for lab in iter_labs(labs_root):
        if lab.lab_id == lab_id:
            return lab
    return None


def phase_entries(metadata: dict[str, object]) -> list[tuple[int, str, str]]:
    phases: list[tuple[int, str, str]] = []
    for key, value in metadata.items():
        if key not in PHASE_LABELS or not value:
            continue
        label, order = PHASE_LABELS[key]
        phases.append((order, label, str(value)))
    return sorted(phases, key=lambda item: (item[0], item[1]))


def count_lab_inventory(labs_root: Path = LABS_ROOT, guide_labs_root: Path = GUIDE_LABS_ROOT) -> tuple[int, int, int]:
    lab_count = len(list(labs_root.rglob("lab.yml")))
    verify_count = len(list(labs_root.rglob("verify.sh")))
    guide_count = len(list(guide_labs_root.rglob("index.md")))
    return lab_count, verify_count, guide_count


def parse_estimated_minutes(time_value: str) -> int:
    minutes = 0
    remaining = time_value
    if "h" in remaining:
        hours, _, remaining = remaining.partition("h")
        minutes += int(hours) * 60
    if "m" in remaining:
        mins, _, _ = remaining.partition("m")
        minutes += int(mins)
    return minutes
