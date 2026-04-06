# Lab 8.5: Building a Supply Chain Security Program

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step done">Assess</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Plan</span>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** 30-day, 90-day, 6-month, and 1-year milestones.

## 30-Day: Foundation

**Theme:** Stop the bleeding. Minimum viable detection. Fix worst config gaps.

| # | Deliverable | Owner |
|:-:|------------|-------|
| 1 | Fix `--extra-index-url` to `--index-url` across all Python projects | Platform |
| 2 | Enable Dependabot on all repositories | Platform |
| 3 | Deploy pip-audit + npm audit in CI (all repos) | AppSec |
| 4 | Publish SECURITY.md in all public repos | Supply Chain Lead |
| 5 | Deploy 3 core SIEM detection rules | AppSec |
| 6 | Appoint Supply Chain Security Lead | CISO |

**Maturity at 30 days: Level 1 (Reactive)**

## 90-Day: Standardization

**Target maturity: Level 2 (Defined).** The 30-day foundation gave you basic scanning and detection. At 90 days, the goal is standardized tooling, documented policies, and developer training. What deliverables would move the organization from Level 1 to Level 2?

| # | Deliverable | Owner |
|:-:|------------|-------|
| 7 | ? | ? |
| 8 | ? | ? |
| 9 | ? | ? |

??? tip "Solution"
    | # | Deliverable | Owner |
    |:-:|------------|-------|
    | 7 | Standardize CI template with Grype + Semgrep | Platform |
    | 8 | Generate CycloneDX SBOMs for all releases | AppSec |
    | 9 | Sign all container images with cosign | Platform |
    | 10 | Publish Dependency Management Standard | AppSec |
    | 11 | Complete IR playbook for supply chain incidents | IR + AppSec |
    | 12 | Nominate security champions (1 per team) | Eng leads |
    | 13 | Complete WeakLink Labs Tier 0-1 for all developers | AppSec |

## 6-Month: Measurement

**Target maturity: Level 3 (Managed).** At 6 months, the goal is metrics-driven security with vendor assessments and SLSA provenance. What deliverables would demonstrate a managed program?

| # | Deliverable | Owner |
|:-:|------------|-------|
| ? | ? | ? |

??? tip "Solution"
    | # | Deliverable | Owner |
    |:-:|------------|-------|
    | 14 | Implement SLSA Level 2 provenance for top 10 services | AppSec + Platform |
    | 15 | Deploy admission controller requiring image signatures | Platform |
    | 16 | Conduct vendor assessments for top 5 critical vendors | Supply Chain Lead |
    | 17 | Launch metrics dashboard | AppSec |
    | 18 | Complete threat model for core platform | AppSec |
    | 19 | Complete first SSDF self-assessment | Supply Chain Lead |

## 1-Year: Optimization

**Target maturity: Level 4 (Optimizing).** At 1 year, the goal is continuous improvement, full SLSA Level 3, and industry-leading practices. What deliverables complete the journey?

| # | Deliverable | Owner |
|:-:|------------|-------|
| ? | ? | ? |

??? tip "Solution"
    | # | Deliverable | Owner |
    |:-:|------------|-------|
    | 20 | SLSA Level 3 for all production services | Platform |
    | 21 | Integrate VEX document generation | AppSec |
    | 22 | Vendor assessments for all critical+high-risk vendors | Supply Chain Lead |
    | 23 | Quarterly threat model updates | AppSec |
    | 24 | Complete EO 14028 compliance package (if selling to fed) | Supply Chain Lead |

## Program metrics

| Metric | Target (90d) | Target (6mo) | Target (1yr) |
|--------|:------------:|:------------:|:------------:|
| % repos with SCA scanning | 100% | 100% | 100% |
| % releases with SBOM | 80% | 100% | 100% |
| % container images signed | 50% | 100% | 100% |
| Mean time to patch critical CVE | <14 days | <7 days | <3 days |
| SLSA level for production services | 0-1 | 2 | 3 |
