# Lab 8.4: Vendor Supply Chain Assessment

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

**Goal:** Produce a vendor risk assessment report.

## Report template

```markdown
VENDOR SUPPLY CHAIN SECURITY ASSESSMENT
=========================================

Vendor:           [Name]
Product:          [Name]
Assessment date:  [Date]
Risk tier:        [Low / Medium / High / Critical]

SCORING SUMMARY
| Section                  | Score | Rating |
|--------------------------|:-----:|:------:|
| Build Integrity          | X/18  |        |
| Dependency Management    | X/18  |        |
| Vulnerability Response   | X/15  |        |
| Transparency             | X/15  |        |
| Incident Management      | X/12  |        |
| **Total**                | X/78  |        |

CRITICAL FINDINGS
| Finding | Risk | Recommendation |
|---------|:----:|----------------|

CONDITIONS FOR APPROVAL (if Medium/High risk)
- [ ] Vendor provides SBOM within [X] days
- [ ] Vendor publishes disclosure policy within [X] days
- [ ] Re-assessment in [6/12] months
```

## Final verification

```bash
weaklink verify 8.4
```

## What You Learned

- Your supply chain security depends on your vendors. SolarWinds, Kaseya, 3CX, and Codecov demonstrated that a vendor compromise becomes your compromise.
- A structured questionnaire removes subjectivity. Scoring across five dimensions gives a defensible evaluation.
- Vendor assessment is a negotiation tool. Sharing results creates leverage to request security improvements.

## Further Reading

- [NIST SP 800-161 Rev. 1: C-SCRM Practices](https://csrc.nist.gov/publications/detail/sp/800-161/rev-1/final)
- [OpenSSF Scorecard](https://securityscorecards.dev/)
- [OWASP Software Component Verification Standard](https://owasp.org/www-project-software-component-verification-standard/)
