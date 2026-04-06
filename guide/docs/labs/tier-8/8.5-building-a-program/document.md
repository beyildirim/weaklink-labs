# Lab 8.5: Building a Supply Chain Security Program

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

**Goal:** One-page executive briefing and program charter.

## Executive briefing

Write a one-page executive briefing using this template structure. Fill in each section based on the target organization profile (Understand) and the milestones you defined (Plan).

```markdown
SUPPLY CHAIN SECURITY PROGRAM: EXECUTIVE BRIEFING
===================================================

THE PROBLEM
[Why does the organization need this program? Cite industry data.]

THE RISK
[Quantify the current exposure: dependency count, signing coverage,
detection gaps, compliance requirements.]

THE PROGRAM
  30 days:  [Summary from your 30-day milestone]
  90 days:  [Summary from your 90-day milestone]
  6 months: [Summary from your 6-month milestone]
  1 year:   [Summary from your 1-year milestone]

INVESTMENT
[What headcount, tooling budget, and developer time is needed?]

REQUEST
[What specific approvals are you asking for?]
```

??? tip "Solution"
    ```markdown
    SUPPLY CHAIN SECURITY PROGRAM: EXECUTIVE BRIEFING
    ===================================================

    THE PROBLEM
    Software supply chain attacks increased 742% between 2019 and 2022 (Sonatype).
    Our current posture: no SBOMs, no artifact signing, no detection rules, no
    formal IR for supply chain events.

    THE RISK
    - 3,400+ open-source dependencies across 47 services
    - 0% of artifacts signed or have build provenance
    - No detection capability for dependency confusion or typosquatting
    - Federal customers beginning to require SBOMs and SSDF attestation

    THE PROGRAM
      30 days:  Fix critical config gaps, deploy basic detection
      90 days:  Standardize tooling, SBOMs, signing, train developers
      6 months: Metrics, vendor assessments, SLSA Level 2
      1 year:   Full maturity at SLSA Level 3, VEX, quarterly threat modeling

    INVESTMENT
    - 1x Supply Chain Security Lead (new hire or internal)
    - 2x AppSec Engineers (existing, partially reallocated)
    - ~$30K/yr for Socket commercial license (all other tools OSS/free)
    - ~2 hours per developer for initial training + 30 min/month ongoing

    REQUEST
    Approve the program charter, the Supply Chain Security Lead role, and
    $30K annual tooling budget.
    ```

## Final verification

```bash
weaklink verify 8.5
```

## What You Learned

- A program is more than tools. Governance, training, monitoring, IR, and continuous improvement are equally important pillars.
- Phased implementation prevents paralysis. 30-day quick wins build credibility for larger investment.
- Metrics create accountability. Tracking SBOM coverage, patch time, and signing percentage makes progress visible to leadership.

## Further Reading

- [OpenSSF Supply Chain Security Guide](https://openssf.org/)
- [SLSA: Supply-chain Levels for Software Artifacts](https://slsa.dev/)
- [NIST SP 800-218: Secure Software Development Framework](https://csrc.nist.gov/publications/detail/sp/800-218/final)
