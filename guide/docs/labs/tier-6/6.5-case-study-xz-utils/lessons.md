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

### Lesson 1: Reproducible builds detect tarball tampering

```bash
cat /app/analysis/reproducible-build-check.sh
/app/analysis/reproducible-build-check.sh
```

Building from git source instead of release tarballs would have excluded the backdoor. An independent rebuild from the same git tag with a fresh `autoreconf` produces a clean binary.

### Lesson 2: Monitor maintainer transitions

Warning signs visible in hindsight:

- Sole maintainer expressing burnout
- New contributor rapidly gaining commit access (18 months to full release access)
- Coordinated pressure from unknown accounts
- Original maintainer stepping back

### Lesson 3: Build from source, not tarballs

```bash
echo "Files in release tarball but NOT in git:"
diff <(ls /app/xz-sources/release-tarball/m4/) <(ls /app/xz-sources/git-checkout/m4/) | grep "^<"
```

Building from the git tag with a fresh `autoreconf` would not have included the malicious m4 script.

### Lesson 4: Support open source maintainers

The attack was enabled by maintainer burnout. Fund critical projects, contribute engineering time, require multi-maintainer sign-off for releases.

### Lesson 5: SBOM enables rapid response

```bash
cat /app/analysis/check-dependency.sh
```

When CVE-2024-3094 dropped, organizations with SBOMs queried "do we use liblzma 5.6.0 or 5.6.1?" in minutes. Those without audited every server manually.

### Verify understanding

```bash
weaklink verify 6.5
```
