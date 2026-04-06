# Lab 3.4: Registry Confusion

<div class="lab-meta">
  <span>~20 min hands-on | ~10 min reference</span>
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

`docker pull myapp:latest` silently rewrites to `docker.io/library/myapp:latest`. This implicit behavior, combined with registry mirrors and search paths, creates an attack surface. An attacker publishes an image with the same name on a registry that takes priority over yours. This is dependency confusion for containers. In 2023, researchers identified widespread typosquatting campaigns on Docker Hub where attackers published images mimicking popular names, accumulating millions of pulls and deploying cryptominers and credential stealers.

### Attack Flow

```mermaid
graph LR
    A[Docker configured with multiple registries] --> B[Attacker publishes same name to public]
    B --> C[Docker pulls from wrong registry]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Private Registry | `registry:5000` | Your organization's registry with `myapp:latest` |
| Attacker Registry | `attacker-registry:5000` | Simulated public registry with malicious `myapp:latest` |
| Workstation | Pod with docker CLI, crane, kubectl | Your working environment |
