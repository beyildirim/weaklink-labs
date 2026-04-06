# Lab 8.4: Vendor Supply Chain Assessment

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

**Goal:** Learn the five assessment dimensions, red flags, and green flags.

## Assessment dimensions

| Dimension | What You Are Evaluating |
|-----------|------------------------|
| **Build integrity** | Can the vendor prove artifacts are built from reviewed source? |
| **Dependency management** | Does the vendor track and manage their dependencies? |
| **Vulnerability response** | How fast does the vendor patch known CVEs? |
| **Transparency** | Does the vendor provide SBOMs, provenance, and security docs? |
| **Incident management** | Does the vendor detect and communicate security incidents? |

## Red flags

| Red Flag | Why It Matters |
|----------|---------------|
| No SBOM available | Cannot assess exposure when a CVE drops |
| Binary releases with no provenance | Trusting vendor's word that binary matches source |
| No vulnerability disclosure policy | No way for researchers to report issues |
| Patch time >30 days for critical CVEs | Unacceptable exposure window |
| Self-hosted builds with no audit | SolarWinds-class risk |
