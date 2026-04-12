# Lab 3.1: Container Image Internals

<div class="lab-meta">
  <span>Understand: ~7 min | Break: ~7 min | Defend: ~6 min | Detect: ~10 min</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-0/0.3-containers/">Lab 0.3</a></span>
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

`docker pull` downloads a **stack of compressed tarballs** (layers), a **manifest** listing them in order, and a **config blob** with metadata. Attackers hide malicious content in layers that appear "deleted" in the final filesystem but remain extractable from the image. In 2020-2021, researchers found dozens of Docker Hub images with cryptominers hidden in intermediate layers, accumulating millions of pulls before removal.

### Attack Flow

```mermaid
graph LR
    A[Pull image] --> B[Inspect layers]
    B --> C[Find hidden content in deleted layer]
    C --> D[Layer history reveals secrets]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| OCI Registry | `registry:5000` | Local registry with pre-loaded images |
| Workstation | Pod with docker CLI, crane, and jq | Your working environment |

> **Related Labs**
>
> - **Prerequisite:** [0.3 How Containers Work](../../tier-0/0.3-containers/index.md) — Basic container concepts before diving into image internals
> - **Next:** [3.2 Tag Mutability Attacks](../3.2-tag-mutability/index.md) — Tag mutability attacks exploit how images are referenced
> - **Next:** [3.5 Layer Injection](../3.5-layer-injection/index.md) — Layer injection manipulates the layer structure covered here
> - **See also:** [4.3 Signing Fundamentals](../../tier-4/4.3-signing-fundamentals/index.md) — Signing fundamentals protect the images analyzed here
