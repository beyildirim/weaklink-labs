# Lab 8.3: Executive Order 14028 Compliance

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

**Goal:** Evaluate the sample application against each requirement.

## SBOM completeness

```bash
cd /app
syft dir:/app -o cyclonedx-json > sbom.json
python3 -m json.tool sbom.json | head -80
```

| NTIA Element | Present? | Complete? | Notes |
|-------------|:--------:|:---------:|-------|
| Supplier name | ? | ? | |
| Component name | ? | ? | |
| Component version | ? | ? | |
| Unique identifier (PURL) | ? | ? | |
| Dependency relationships | ? | ? | |
| SBOM author | ? | ? | |
| Timestamp | ? | ? | |

**Common gaps:** Transitive deps missing, system packages not included, no PURLs, supplier name missing.

## Compliance scorecard

| Requirement | Status | Readiness |
|-------------|--------|:---------:|
| SBOM generation | Partial (generated but incomplete) | 60% |
| SBOM delivery mechanism | Not implemented | 20% |
| VEX documents | Not implemented | 0% |
| Vulnerability disclosure policy | Not published | 10% |
| Incident notification process | Playbook exists ([Lab 7.3](../../../tier-7/7.3-ir-playbook/)) | 40% |
| SSDF self-attestation | Draft from [Lab 8.2](../8.2-ssdf-nist/) | 50% |

---

???+ success "Checkpoint"
    You should have a compliance scorecard showing readiness percentage for each of the 5 EO 14028 requirements. Most projects score below 50% on first assessment.
