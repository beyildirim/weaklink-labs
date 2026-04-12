from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from weaklink_platform.lab_runtime import verifier_exists
from weaklink_platform.manifest import (
    PHASE_LABELS,
    LabManifest,
    load_lab_manifest,
    parse_estimated_minutes as _parse_estimated_minutes,
)
from weaklink_platform.paths import GUIDE_LABS_ROOT, LABS_ROOT


@dataclass(frozen=True)
class Lab:
    manifest: LabManifest
    tier_name: str
    lab_dir: Path

    @property
    def lab_id(self) -> str:
        return self.manifest.id

    @property
    def title(self) -> str:
        return self.manifest.title

    @property
    def tier(self) -> int:
        return self.manifest.tier

    @property
    def metadata(self) -> dict[str, object]:
        return self.manifest.to_metadata()


def _tier_name_from_dir(tier_dir: Path) -> str:
    parts = tier_dir.name.split("-", 2)
    suffix = parts[2] if len(parts) > 2 else tier_dir.name
    return " ".join(part.capitalize() for part in suffix.split("-"))


def iter_labs(labs_root: Path = LABS_ROOT) -> list[Lab]:
    labs: list[Lab] = []
    for tier_dir in sorted(p for p in labs_root.glob("tier-*") if p.is_dir()):
        tier_name = _tier_name_from_dir(tier_dir)
        for lab_dir in sorted(p for p in tier_dir.iterdir() if p.is_dir()):
            manifest = lab_dir / "lab.yml"
            if not manifest.exists():
                continue
            labs.append(
                Lab(
                    manifest=load_lab_manifest(lab_dir),
                    tier_name=tier_name,
                    lab_dir=lab_dir,
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
    labs = iter_labs(labs_root)
    lab_count = len(labs)
    verify_count = sum(1 for lab in labs if verifier_exists(lab.lab_dir))
    guide_count = len(list(guide_labs_root.rglob("index.md")))
    return lab_count, verify_count, guide_count


parse_estimated_minutes = _parse_estimated_minutes
