# Lab 0.3: How Containers Work

<div class="lab-meta">
  <span>Understand: ~8 min | Break: ~8 min | Defend: ~9 min | Detect: ~5 min</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-0/0.2-package-managers/">Lab 0.2</a></span>
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

Containers are how modern software is packaged and deployed. When you pull a Docker image, you trust that it contains what you expect. But container tags like `latest` are mutable. They can be changed to point to a completely different image at any time.

### Attack Flow

```mermaid
graph LR
    A[Developer pulls image:latest] -->|Gets safe image| B[App runs normally]
    B -->|Time passes| C[Attacker pushes backdoored image with same tag]
    C -->|Developer pulls latest again| D[Registry returns backdoored image]
    D --> E[Backdoor runs in production]
```

## Environment

| Service        | Address              |
|----------------|----------------------|
| Local Registry | `registry:5000`      |

> **Related Labs**
>
> - **Prerequisite:** [0.2 How Package Managers Work](../0.2-package-managers/index.md) — Container images bundle application code and its dependencies
> - **Next:** [3.1 Container Image Internals](../../tier-3/3.1-image-internals/index.md) — Deep dive into how container images are structured internally
> - **Next:** [0.5 Artifacts & Registries](../0.5-artifacts-registries/index.md) — Registries store container images alongside other artifacts
> - **See also:** [3.3 Base Image Poisoning](../../tier-3/3.3-base-image-poisoning/index.md) — What happens when someone poisons the base image you build on
