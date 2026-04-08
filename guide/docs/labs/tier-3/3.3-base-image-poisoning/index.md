# Lab 3.3: Base Image Poisoning

<div class="lab-meta">
  <span>Understand: ~8 min | Break: ~8 min | Defend: ~9 min | Detect: ~10 min</span>
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

Every Dockerfile starts with `FROM`. That single line imports an entire OS, runtime, and all its dependencies. If the base image is compromised, every image built on top of it inherits the backdoor. A poisoned `python:3.12` or `node:20` affects every application built `FROM` it.

### Attack Flow

```mermaid
graph LR
    A[Upstream base compromised] --> B[Dev builds FROM base]
    B --> C[App inherits backdoor]
    C --> D[Deployed to prod]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| OCI Registry | `registry:5000` | Contains `python-base:3.12` (poisoned) and build artifacts |
| Workstation | Pod with docker CLI, crane, trivy | Your working environment |
