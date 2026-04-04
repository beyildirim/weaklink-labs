# Achievements & Badges

WeakLink Labs includes a local achievement system that tracks your progress and generates shareable badges. All badge generation happens offline -- no data leaves your machine.

## All Achievements

| Badge | Achievement | Requirement |
|-------|------------|-------------|
| `[chain]` | **First Link** | Complete any 1 lab |
| `[shield]` | **Foundation Builder** | Complete all Tier 0 labs |
| `[crosshair]` | **Package Hunter** | Complete all Tier 1 labs |
| `[pipe]` | **Pipeline Breaker** | Complete all Tier 2 labs |
| `[box]` | **Container Escape Artist** | Complete all Tier 3 labs |
| `[lock]` | **Integrity Guardian** | Complete all Tier 4 labs |
| `[cloud]` | **Infrastructure Infiltrator** | Complete all Tier 5 labs |
| `[skull]` | **Advanced Operator** | Complete all Tier 6 labs |
| `[siren]` | **Incident Commander** | Complete all Tier 7 labs |
| `[blueprint]` | **Program Architect** | Complete all Tier 8 labs |
| `[gold-chain]` | **Supply Chain Defender** | Complete Tiers 0-5 |
| `[platinum]` | **Weakest Link No More** | Complete ALL labs |

## Checking Your Achievements

```bash
weaklink achieve
```

Shows all achievements with their current status (locked/unlocked) and completion dates:

```
  WEAKLINK LABS ACHIEVEMENTS

  Unlocked:
    [chain] First Link (First Lab)                 2026-04-04
    [shield] Foundation Builder (Tier 0)            2026-04-04
    [crosshair] Package Hunter (Tier 1)                2026-04-04

  Locked:
    [pipe] Pipeline Breaker (Tier 2)              Complete all Tier 2 labs
    [box] Container Escape Artist (Tier 3)       Complete all Tier 3 labs
    ...

  Progress: 3/12 achievements unlocked
```

## Generating Badges

```bash
weaklink achieve --generate
```

Generates an SVG badge file for each unlocked achievement in `~/.weaklink/badges/`.

Each badge is a 600x300 pixel inline SVG with:

- Dark gradient background (#1a1a2e to #16213e)
- Colored accent bar matching the achievement tier
- WeakLink Labs branding
- Achievement name and description
- Your name (from `git config user.name`)
- Completion date
- Unique verification ID (first 8 chars of a sha256 hash)

The SVGs have no external dependencies and render cleanly in any browser, GitHub README, or image viewer.

### Tier accent colors

| Tier | Color |
|------|-------|
| Tier 0 | Teal (#4ecdc4) |
| Tier 1 | Red (#ff6b6b) |
| Tier 2 | Orange (#ffa502) |
| Tier 3 | Blue (#3498db) |
| Tier 4 | Green (#2ecc71) |
| Tier 5 | Purple (#9b59b6) |
| Tier 6 | Dark Red (#e74c3c) |
| Tier 7 | Amber (#e67e22) |
| Tier 8 | Emerald (#1abc9c) |
| Supply Chain Defender | Gold (#f1c40f) |
| Weakest Link No More | Platinum (#ecf0f1) |

## Sharing on LinkedIn

```bash
weaklink achieve --share
```

Generates SVG badges **and** a LinkedIn post text file for each unlocked achievement:

```
~/.weaklink/badges/
  package-hunter.svg
  package-hunter-linkedin.txt
```

Each LinkedIn text file contains a ready-to-post message:

> Completed the Package Hunter track on WeakLink Labs - an open-source, hands-on supply chain security training platform. Explored dependency confusion, typosquatting, lockfile injection, manifest confusion, and phantom dependencies in package ecosystems. #SupplyChainSecurity #AppSec #WeakLinkLabs

You can also add the SVG badges directly to your GitHub profile README.

## Proof Attestations

```bash
weaklink achieve --proof
```

Generates a JSON attestation file for each unlocked achievement:

```json
{
  "platform": "weaklink-labs",
  "version": "0.1.0",
  "achievement": "package-hunter",
  "title": "Package Hunter",
  "user": "baris",
  "labs_completed": ["1.1", "1.2", "1.3", "1.4", "1.5", "1.6"],
  "completed_at": "2026-04-04T12:00:00Z",
  "verification_id": "WL-a7f3b2c9",
  "challenge_hash": "sha256:..."
}
```

The `challenge_hash` is a sha256 of the concatenated completion timestamps from your local progress, tying the attestation to actual lab completion.

The `verification_id` is derived from your username, achievement ID, and completion date, making each badge uniquely verifiable.

## Combining Flags

You can combine flags in a single command:

```bash
# Generate everything at once
weaklink achieve --share --proof
```

This produces SVG badges, LinkedIn posts, and JSON attestations for all unlocked achievements.

## Output Location

All generated files are written to `~/.weaklink/badges/`:

```
~/.weaklink/badges/
  first-link.svg
  first-link-linkedin.txt
  first-link-proof.json
  foundation-builder.svg
  foundation-builder-linkedin.txt
  foundation-builder-proof.json
  ...
```
