# Lab 8.5: Building a Supply Chain Security Program

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

**Goal:** Design the complete program: governance, tooling, training, monitoring, IR.

## Governance structure

| Role | Responsibility |
|------|---------------|
| Supply Chain Security Lead | Program strategy, vendor assessments, framework compliance |
| AppSec Engineer (x2) | Tooling, CI/CD integration, detection rules |
| Security Champion (per team) | Dependency review, security training liaison |

**Policy documents:** Supply Chain Security Policy, Dependency Management Standard, Artifact Integrity Standard, SBOM Policy, Vendor Assessment Policy, IR Playbook: Supply Chain.

## Tooling architecture

Before designing the tooling architecture, discover what tools are already available on the workstation:

```bash
which cosign syft grype trivy crane helm kubectl docker 2>/dev/null
pip-audit --version 2>/dev/null
npm audit --help 2>/dev/null | head -1
semgrep --version 2>/dev/null
```

Based on the tools you found, design a three-stage tooling architecture:

1. **Developer workstation** (pre-commit): What checks run before code leaves the developer's machine?
2. **CI/CD pipeline** (build time): What scanning and integrity checks run during builds?
3. **Post-build** (release time): What signing, SBOM, and provenance steps run after build?

Draw the architecture as a diagram or table mapping each available tool to its stage.

??? tip "Solution"
    ```
    Developer Workstation          CI/CD Pipeline              Post-Build
    ┌───────────────────┐   ┌────────────────────────┐   ┌──────────────────┐
    │ pre-commit hooks  │   │ Dependency scanning    │   │ Container signing│
    │ - detect secrets  │──>│ - pip-audit / npm audit │──>│ - cosign         │
    │ - lockfile check  │   │ - Grype (vuln scan)    │   │ SBOM generation  │
    │                   │   │ - Socket (behavioral)  │   │ - Syft/CycloneDX │
    │                   │   │                        │   │ SLSA provenance  │
    │                   │   │ Build integrity        │   │ - slsa-generator │
    │                   │   │ - pinned Actions (SHA) │   └──────────────────┘
    │                   │   │ - --require-hashes     │
    │                   │   │ - Semgrep (SAST)       │
    │                   │   └────────────────────────┘
    ```

## Monitoring and detection

| Detection | Source | Alert Destination |
|-----------|--------|-------------------|
| Dependency confusion | Proxy logs | PagerDuty (P1) |
| Typosquatting | CI logs | Slack #security-alerts |
| Lockfile injection | Git audit | PR comment (block merge) |
| Malicious install scripts | EDR | PagerDuty (P2) |
| Secret in commit | CI (Gitleaks) | Block push / PR |
| CVE >= High in dependency | CI (Grype) | Block merge (PR check) |

---

???+ success "Checkpoint"
    You should have governance structure, tooling architecture, and detection matrix defined. These three components form the operational backbone of the program.
