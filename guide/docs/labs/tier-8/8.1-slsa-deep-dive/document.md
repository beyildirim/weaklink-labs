# Lab 8.1: SLSA Framework Deep Dive

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step done">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step done">Plan</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Document</span>
</div>

**Goal:** Complete a SLSA self-assessment template for auditors.

## Self-assessment template

```markdown
SLSA SELF-ASSESSMENT
====================

Project:          [Project name]
Repository:       [GitHub URL]
Assessment date:  [Date]
Current level:    [0 / 1 / 2 / 3]
Target level:     [1 / 2 / 3]

BUILD PLATFORM:      [GitHub Actions / GitLab CI / Cloud Build / other]
Runner type:         [Hosted / Self-hosted]
Runner lifecycle:    [Ephemeral / Persistent]

PROVENANCE:          [Generated: Y/N] [Format: in-toto/custom/none]
                     [Signed: Y/N (method)] [Stored: OCI/Rekor/other]

BUILD INTEGRITY:     [Isolated: Y/N] [Parameterless: Y/N] [Hermetic: Y/N]
                     [Deps pinned to hash: Y/Partial/N] [Actions pinned to SHA: Y/Partial/N]

GAP ANALYSIS
| Requirement | Current | Target | Remediation |
|-------------|---------|--------|-------------|

TIMELINE
| Date | Milestone | Owner |
|------|-----------|-------|
```

## Final verification

```bash
weaklink verify 8.1
```

## What You Learned

- SLSA is a maturity model. Each level progressively reduces trust assumptions in your build process.
- Level 1 is achievable in a day. Level 3 requires architectural changes (parameterless builds, hermetic deps, isolated runners).
- Provenance without verification is theater. Deployment policies must verify provenance before promoting artifacts.

## Further Reading

- [SLSA v1.0 Specification](https://slsa.dev/spec/v1.0/)
- [SLSA GitHub Generator](https://github.com/slsa-framework/slsa-github-generator)
- [Sigstore: Keyless Signing for Software Artifacts](https://www.sigstore.dev/)
