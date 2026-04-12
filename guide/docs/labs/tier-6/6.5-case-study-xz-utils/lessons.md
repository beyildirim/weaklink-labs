# Lab 6.5: Case Study: xz-utils (CVE-2024-3094)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Lessons</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Defense Takeaways

**Goal:** Extract actionable defenses that apply to every organization consuming open source software.

### Lesson 1: Create a reproducibility review script

```bash
cat > /app/check_reproducible.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "sha256 review of source-side evidence:"
sha256sum /app/timeline/attack-timeline.md /app/indicators/iocs.txt

echo
echo "compare timeline and indicator excerpts during review:"
diff -u <(grep -n '2024' /app/timeline/attack-timeline.md) <(grep -n '5.6' /app/indicators/iocs.txt) || true

echo
echo "compare source-derived artifacts and release-only contents during a reproducible build review."
EOF

chmod +x /app/check_reproducible.sh
bash /app/check_reproducible.sh
```

The script is a placeholder for the real control: independently rebuild from reviewed source and compare release outputs instead of trusting tarballs blindly.

### Lesson 2: Monitor maintainer transitions

Warning signs visible in hindsight:

- Sole maintainer expressing burnout
- New contributor rapidly gaining commit access (18 months to full release access)
- Coordinated pressure from unknown accounts
- Original maintainer stepping back

### Lesson 3: Build from source, not tarballs

```bash
cat >> /app/analysis.md <<'EOF'

## Defensive takeaways
Build from reviewed source rather than trusting release tarballs blindly.
Watch for maintainer burnout, unusual pressure campaigns, and sudden maintainer transitions.
Use SBOM data to answer "where do we use liblzma?" quickly when a disclosure lands.
EOF
```

This lab intentionally makes you write down the lessons instead of only reading them. Your own `analysis.md` is part of the deliverable.

### Lesson 4: Support open source maintainers

The attack was enabled by maintainer burnout. Fund critical projects, contribute engineering time, require multi-maintainer sign-off for releases.
