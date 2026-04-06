# Lab 8.2: SSDF / NIST SP 800-218 Mapping

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

**Goal:** Learn the four practice areas and the supply chain-critical sub-practices.

## The four practice areas

| Practice Area | Code | Focus |
|--------------|------|-------|
| **Prepare the Organization** | PO | Governance, roles, training, tooling |
| **Protect the Software** | PS | Source code, build systems, artifact integrity |
| **Produce Well-Secured Software** | PW | Design, implementation, testing, vulnerability management |
| **Respond to Vulnerabilities** | RV | Monitoring, disclosure, remediation |

## Key sub-practices for supply chain security

| Task ID | Description | Supply Chain Relevance |
|---------|-------------|----------------------|
| **PO.3.1** | Specify tools and tool configuration | Defines required SCA, SAST, SBOM tools |
| **PS.2.1** | Protect all forms of code from tampering | Includes build scripts, CI configs, IaC |
| **PS.3.1** | Archive and protect each software release | Immutable artifacts, signed releases |
| **PW.4.1** | Acquire well-secured components | Dependency management, registry hardening |
| **PW.4.4** | Verify integrity of acquired components | Hash verification, signature checking, provenance |
| **RV.1.1** | Gather vulnerability information | Vulnerability monitoring (Dependabot, Grype) |
| **RV.3.3** | Provide SBOMs to software consumers | SBOM generation and distribution |
