# Lab 6.5: Case Study: xz-utils (CVE-2024-3094)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Timeline of a Two-Year Social Engineering Campaign

**Goal:** Trace how the attacker gained commit access through social engineering and maintainer burnout exploitation.

### Step 1: The timeline

```bash
cat /app/timeline/attack-timeline.md
```

| Date | Event |
|------|-------|
| 2021-10 | "Jia Tan" begins submitting patches to xz-utils |
| 2022-01 | Sock puppet accounts pressure Lasse Collin to add a co-maintainer |
| 2022-09 | Jia Tan granted commit access |
| 2023-01 | Jia Tan becomes de facto primary maintainer |
| 2024-02-15 | Backdoor injected into xz-utils 5.6.0 |
| 2024-03-09 | Backdoor carried into 5.6.1 |
| 2024-03-29 | Andres Freund discovers the backdoor; CVE-2024-3094 assigned |

### Step 2: The social engineering

```bash
cat /app/indicators/iocs.txt
```

The IOC notes are short, but they capture the signals that mattered: vulnerable versions `5.6.0` and `5.6.1`, release-tarball tampering, and the suspicious test files used to hide payload data.

### Step 3: Trust building

Jia Tan's initial contributions were genuine: test fixes, documentation, minor bugs. Over 18 months, they built a commit history that made the eventual backdoor commit unremarkable.

### Step 4: Start your analysis document

Create the file the lab verifier expects and capture the social-engineering side of the case:

```bash
cat > /app/analysis.md <<'EOF'
# xz-utils Case Study Analysis

## Social engineering timeline
Jia Tan spent roughly two years building trust before the xz-utils backdoor was discovered.
The case is a maintainer burnout story as much as it is a technical compromise:
an overworked maintainer faced sustained pressure to hand over more responsibility.

## Discovery
Andres Freund noticed unusual SSH latency and traced it back to a malicious liblzma path.
EOF
```

You will add the build-system and defense details in the next phases.
