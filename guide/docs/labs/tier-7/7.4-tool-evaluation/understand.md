# Lab 7.4: Supply Chain Security Tool Evaluation

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step upcoming">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="../validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Survey the tool landscape and understand what category each tool belongs to.

## Step 1: Tool categories

| Category | What It Does | Tools |
|----------|-------------|-------|
| **Vulnerability scanning** | Finds known CVEs in dependencies | Grype, Trivy, pip-audit, npm audit, Snyk |
| **Behavioral analysis** | Detects suspicious package behavior (network, file access, obfuscation) | Socket |
| **Dependency risk scoring** | Scores project health, maintainer trust, dependency hygiene | OpenSSF Scorecard, deps.dev |
| **SBOM & provenance** | Generates/validates SBOMs and build provenance | Syft, cosign, SLSA verifier |
| **Dependency graph analysis** | Maps and queries the dependency graph for anomalies | GUAC, deps.dev |
| **Automated updates** | Keeps dependencies current with automated PRs | Dependabot, Renovate |

## Step 2: Map tools to Tier 1 attack types

| Attack Type | Expected Detection By |
|-------------|----------------------|
| Dependency confusion | Socket (behavioral), Scorecard (config check) |
| Typosquatting | Socket (name analysis), deps.dev (popularity) |
| Lockfile injection | npm audit (integrity check), Socket (diff analysis) |
| Manifest confusion | Socket (metadata analysis) |
| Phantom dependencies | deps.dev (graph analysis), Scorecard (pinning check) |
| Known CVEs | Grype, Trivy, pip-audit, npm audit, Snyk |
