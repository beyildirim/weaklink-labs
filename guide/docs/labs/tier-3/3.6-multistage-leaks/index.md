# Lab 3.6: Multi-Stage Build Leaks

<div class="lab-meta">
  <span>Understand: ~7 min | Break: ~7 min | Defend: ~6 min | Detect: ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../3.1-image-internals/">Lab 3.1</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

Multi-stage builds separate build tools from production images. But developers routinely leak secrets through this boundary: `ENV`/`ARG` values persisting in layer history, overbroad `COPY` instructions, and missing `.dockerignore` files. This lab exposes an API key from a "clean-looking" final image using three extraction techniques. In 2023, Sysdig researchers scanned public Docker Hub images and found thousands of exposed AWS keys, GCP credentials, and private SSH keys embedded in image layers, many still valid.

### Attack Flow

```mermaid
graph LR
    A[Build stage uses API key] --> B[COPY copies too broadly]
    B --> C[Key ends up in final image]
    C --> D[Extracted by attacker]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Workstation | `weaklink-ws` | Has docker CLI, dive, crane, and jq |
| Registry | `registry:5000` | Local registry with pre-built images |

> **Related Labs**
>
> - **Prerequisite:** [3.1 Container Image Internals](../3.1-image-internals/index.md) — Image internals including multi-stage build mechanics
> - **See also:** [2.4 Secret Exfiltration from CI](../../tier-2/2.4-secret-exfiltration/index.md) — Both involve secrets leaking from build environments
> - **See also:** [3.5 Layer Injection](../3.5-layer-injection/index.md) — Layer injection targets the same layer structure that leaks here
> - **See also:** [4.2 SBOM Gaps in Practice](../../tier-4/4.2-sbom-gaps/index.md) — SBOM gaps miss dependencies only present in intermediate stages
