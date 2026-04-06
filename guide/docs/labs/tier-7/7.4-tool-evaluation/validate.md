# Lab 7.4: Supply Chain Security Tool Evaluation

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../investigate/" class="phase-step done">Investigate</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Validate</span>
  <span class="phase-arrow">›</span>
  <a href="../improve/" class="phase-step upcoming">Improve</a>
</div>

**Goal:** Consolidate findings into a comparison matrix.

## Detection coverage matrix

| Attack Type | pip-audit | npm audit | Grype | Trivy | Snyk | Socket | Scorecard | deps.dev |
|-------------|:---------:|:---------:|:-----:|:-----:|:----:|:------:|:---------:|:--------:|
| Known CVEs | Yes | Yes | Yes | Yes | Yes | Partial | No | Yes |
| Dependency confusion | No | No | No | No | No | **Yes** | Partial | No |
| Typosquatting | No | No | No | No | Partial | **Yes** | No | Partial |
| Lockfile injection | No | Partial | No | No | No | **Yes** | No | No |
| Manifest confusion | No | No | No | No | No | **Yes** | No | No |
| Phantom dependencies | No | No | No | No | No | Partial | Partial | Partial |
| Malicious install scripts | No | No | No | No | No | **Yes** | No | No |
| Secrets in code | No | No | No | **Yes** | Partial | No | No | No |
| Dockerfile misconfig | No | No | No | **Yes** | Partial | No | No | No |

**Key insight:** Vulnerability scanners only catch *known CVEs*. They miss every Tier 1 attack type because those attacks use packages not in vulnerability databases.

## Operational comparison

| Tool | Cost | Integration Effort | False Positive Rate |
|------|------|--------------------|---------------------|
| pip-audit | Free (OSS) | Low | Low |
| npm audit | Free (built-in) | None | Medium |
| Grype | Free (OSS) | Low | Low-Medium |
| Trivy | Free (OSS) | Low | Low-Medium |
| Snyk | Freemium ($$$) | Medium | Low |
| Socket | Freemium ($$) | Medium | Medium |
| Scorecard | Free (OSS) | Low | Low |
| deps.dev | Free | Medium | Low |
