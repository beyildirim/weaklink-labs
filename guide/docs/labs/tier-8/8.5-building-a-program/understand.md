# Lab 8.5: Building a Supply Chain Security Program

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step upcoming">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="../plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Learn the six pillars and the target organization profile.

## The six pillars

| Pillar | WeakLink Labs Coverage |
|--------|----------------------|
| **Governance** | Labs 8.1-8.4 (SLSA, SSDF, EO 14028, vendor assessment) |
| **Tooling** | Labs 1.1-5.x, 7.4 (SCA, SBOM, signing, container security) |
| **Training** | All labs (developer awareness of attack vectors and defenses) |
| **Monitoring** | Labs 7.1, 7.5 (detection rules, threat modeling) |
| **Incident Response** | Labs 7.2, 7.3 (triage, playbooks) |
| **Continuous Improvement** | Labs 7.5, 8.5 (metrics, threat model updates) |

## Target organization

- **500 employees, 200 developers**
- Cloud-native (Kubernetes, microservices), Python/TypeScript/Go
- GitHub Actions, AWS, ghcr.io
- **Current state**: Dependabot on some repos. No SBOM, no signing, no detection rules, ad-hoc IR.

## Maturity model

| Level | Name | Description |
|:-----:|------|-------------|
| 0 | **Ad-hoc** | No formal supply chain security. Current state. |
| 1 | **Reactive** | Basic vuln scanning. Patches when alerted. |
| 2 | **Defined** | Documented policies. Standardized tooling. Detection rules. |
| 3 | **Managed** | Metrics tracked. Vendor assessments. SBOM/VEX. Tested playbooks. |
| 4 | **Optimizing** | Continuous improvement. Quarterly threat models. Industry-leading. |
