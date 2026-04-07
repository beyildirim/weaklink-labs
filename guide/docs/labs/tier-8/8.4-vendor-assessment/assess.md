# Lab 8.4: Vendor Supply Chain Assessment

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Assess</span>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Apply the questionnaire against the sample application as a vendor product.

## Questionnaire

Score each question: **3** = Fully met with evidence, **2** = Partial, **1** = Minimal/none.

??? note "Section A: Build Integrity (6 questions)"
    | # | Question | Score | Evidence |
    |:-:|----------|:-----:|----------|
    | A1 | Hosted CI/CD platform? | | |
    | A2 | Artifacts signed (cosign, GPG, Sigstore)? | | |
    | A3 | SLSA provenance generated? What level? | | |
    | A4 | Provenance independently verifiable? | | |
    | A5 | Build configs version-controlled? | | |
    | A6 | Reproducible builds? | | |

??? note "Section B: Dependency Management (6 questions)"
    | # | Question | Score | Evidence |
    |:-:|----------|:-----:|----------|
    | B1 | Dependencies pinned to exact versions? | | |
    | B2 | Hash verification for dependencies? | | |
    | B3 | Lockfiles used? | | |
    | B4 | Dependencies updated regularly? | | |
    | B5 | Automated updates (Dependabot, Renovate)? | | |
    | B6 | New dependencies evaluated before adoption? | | |

??? note "Section C: Vulnerability Response (5 questions)"
    | # | Question | Score | Evidence |
    |:-:|----------|:-----:|----------|
    | C1 | Published vulnerability disclosure policy? | | |
    | C2 | Median time to patch critical CVEs? | | |
    | C3 | Security advisories published? | | |
    | C4 | Automated vulnerability scanning in CI? | | |
    | C5 | Defined remediation SLAs? | | |

??? note "Section D: Transparency (5 questions)"
    | # | Question | Score | Evidence |
    |:-:|----------|:-----:|----------|
    | D1 | SBOMs with each release? | | |
    | D2 | SBOM format (CycloneDX, SPDX)? | | |
    | D3 | SBOMs meet NTIA minimum elements? | | |
    | D4 | VEX documents provided? | | |
    | D5 | Source code auditable? | | |

??? note "Section E: Incident Management (4 questions)"
    | # | Question | Score | Evidence |
    |:-:|----------|:-----:|----------|
    | E1 | Documented IR process? | | |
    | E2 | Customer notification commitment? | | |
    | E3 | Past incidents disclosed transparently? | | |
    | E4 | SOC 2 Type II or equivalent? | | |

## Gather evidence

```bash
ls /app/SECURITY.md /app/sbom* 2>/dev/null
cat /app/.github/workflows/build.yml 2>/dev/null
grep -r "cosign\|sigstore" /app/.github/ 2>/dev/null
ls /app/.github/dependabot.yml 2>/dev/null
```

---

???+ success "Checkpoint"
    You should have scores for all 5 sections. Calculate the total out of 78. This score determines the risk tier.
