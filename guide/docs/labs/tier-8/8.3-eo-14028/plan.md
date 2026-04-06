# Lab 8.3: Executive Order 14028 Compliance

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

**Goal:** Specific deliverables and timelines per requirement.

## SBOM compliance

| # | Action | Timeline |
|:-:|--------|:--------:|
| 1 | Add SBOM generation to CI | Week 1 |
| 2 | Validate SBOM against NTIA minimum elements in CI | Week 1 |
| 3 | Include transitive dependencies | Week 2 |
| 4 | Add PURL identifiers | Week 2 |
| 5 | Include container base image components (Syft) | Week 3 |
| 6 | Automate SBOM delivery with each release | Week 3 |

## VEX compliance

| # | Action | Timeline |
|:-:|--------|:--------:|
| 1 | Choose format (recommend OpenVEX) | Week 1 |
| 2 | Inventory known CVEs in current deps | Week 1 |
| 3 | Assess exploitability per CVE | Week 2-3 |
| 4 | Generate initial VEX document | Week 3 |

**OpenVEX example:**

```json
{
  "@context": "https://openvex.dev/ns/v0.2.0",
  "author": "WeakLink Corp Security Team",
  "timestamp": "2026-04-01T12:00:00Z",
  "statements": [
    {
      "vulnerability": {"@id": "https://nvd.nist.gov/vuln/detail/CVE-2024-12345"},
      "products": [{"@id": "pkg:docker/wl/webapp@v2.14.3"}],
      "status": "not_affected",
      "justification": "vulnerable_code_not_in_execute_path"
    }
  ]
}
```

## Vulnerability disclosure

Publish a `SECURITY.md` in all repos with: reporting email, PGP key link, response SLAs (Acknowledge: 48h, Critical fix: 48h, High: 7d, Medium: 30d).
