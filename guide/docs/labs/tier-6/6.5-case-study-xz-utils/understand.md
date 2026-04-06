# Lab 6.5: Case Study. xz-utils (CVE-2024-3094)

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
cat /app/analysis/timeline.txt
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
cat /app/analysis/mailing-list-excerpts.txt
```

Multiple sock puppet accounts ("Jigar Kumar", "Dennis Ens") complained about Collin's responsiveness, creating the appearance of community demand for a co-maintainer.

### Step 3: Trust building

```bash
cat /app/xz-sources/early-commits.log
```

Jia Tan's initial contributions were genuine: test fixes, documentation, minor bugs. Over 18 months, they built a commit history that made the eventual backdoor commit unremarkable.
