# Lab 8.6: OWASP SCVS Framework Assessment

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

**Goal:** Evaluate all 6 categories, map gaps to specific labs.

## Assess V1 (Inventory) and V4 (Package Management)

Check V1 (Inventory) and V4 (Package Management) controls:

```bash
ls /app/requirements.txt /app/package.json /app/package-lock.json 2>/dev/null
grep -E '==' /app/requirements.txt 2>/dev/null | head -5
grep -E '--hash' /app/requirements.txt 2>/dev/null | head -3
grep -E 'index-url|registry' /app/.npmrc /app/pip.conf 2>/dev/null
```

## Assess V2 (SBOM) and V3 (Build Environment)

Check V2 (SBOM) and V3 (Build Environment) controls:

```bash
grep -rE 'syft|cyclonedx|spdx|sbom' /app/.github/workflows/ 2>/dev/null
grep -rE 'slsa|provenance|cosign' /app/.github/workflows/ 2>/dev/null
grep -E '@[a-f0-9]{40}' /app/.github/workflows/*.yml 2>/dev/null
```

## Assess V5 (Component Analysis) and V6 (Provenance)

Check V5 (Component Analysis) and V6 (Provenance) controls:

```bash
grep -rE 'grype|trivy|pip-audit|dependabot' /app/.github/workflows/ /app/.github/dependabot.yml 2>/dev/null
grep -rE 'cosign verify|slsa-verifier' /app/.github/workflows/ 2>/dev/null
```

## Map gaps to labs

| SCVS Category | Gap | WeakLink Lab |
|---------------|-----|-------------|
| V1 | No automated inventory beyond lockfile | [Lab 4.1](../../tier-4/4.1-sbom-contents.md) |
| V2 | No SBOM generated | [Lab 4.1](../../tier-4/4.1-sbom-contents.md) |
| V3 | No SLSA provenance, Actions not pinned to SHA | [Lab 4.4](../../tier-4/4.4-attestation-slsa.md) |
| V4 | No hash verification, using `--extra-index-url` | [Lab 1.2](../../tier-1/1.2-dependency-confusion/) |
| V5 | No automated scanning, no remediation SLAs | [Lab 7.4](../../tier-7/7.4-tool-evaluation/) |
| V6 | No signature verification, no upstream health checks | [Lab 4.5](../../tier-4/4.5-signature-bypass.md) |

---

???+ success "Checkpoint"
    You should have a per-category assessment (Met/Partial/Not Met for each maturity level) and a gap-to-lab mapping. This is the input to the remediation roadmap.
