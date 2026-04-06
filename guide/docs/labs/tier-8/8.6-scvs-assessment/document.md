# Lab 8.6: OWASP SCVS Framework Assessment

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

**Goal:** Produce a SCVS compliance report with overlap matrix.

## Report structure

1. **Executive summary** with overall maturity level per category
2. **Detailed findings** for each of the 6 SCVS categories with evidence
3. **Prioritized remediation roadmap** from Plan
4. **Framework overlap summary** showing multi-framework coverage

## Continuous compliance metrics

| Metric | SCVS Category | Target |
|--------|:------------:|:------:|
| % projects with component inventory | V1 | 100% |
| % releases with SBOM | V2 | 100% |
| SLSA level of production builds | V3 | Level 2+ |
| % dependencies with verified hashes | V4 | 100% |
| Mean time to remediate critical CVEs | V5 | < 48h |
| % artifacts with verified provenance | V6 | 100% |

## Final verification

```bash
weaklink verify 8.6
```

## What You Learned

- SCVS is the most comprehensive component-level checklist: 6 categories, ~65 controls covering inventory through provenance.
- Frameworks complement, they do not compete. Use SCVS for technical depth, SLSA for build maturity, SSDF for governance.
- Multi-framework controls (SBOM generation, artifact signing, vuln scanning) each satisfy 3+ frameworks simultaneously. Prioritize these.

## Further Reading

- [OWASP SCVS](https://owasp.org/www-project-software-component-verification-standard/)
- [OWASP CycloneDX](https://cyclonedx.org/)
- [OWASP Dependency-Track](https://dependencytrack.org/)
