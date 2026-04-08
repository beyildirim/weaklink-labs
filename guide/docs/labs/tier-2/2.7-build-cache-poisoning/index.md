# Lab 2.7: Build Cache Poisoning

<div class="lab-meta">
  <span>Understand: ~7 min | Break: ~7 min | Defend: ~6 min | Detect: ~15 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../2.1-cicd-fundamentals/">Lab 2.1</a></span>
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

CI systems cache dependencies, build outputs, and Docker layers to speed up pipelines. The cache is keyed by a hash (typically the lockfile) and shared across workflow runs. If an attacker can poison the cache by inserting a modified dependency, every subsequent build using that cache key silently uses the malicious version. The attack remains viable when cache keys are weak, when PR caches are not isolated, or when self-hosted caching infrastructure is used. Legit Security's 2022 research demonstrated that GitHub Actions caches could be poisoned from a pull request and restored by default branch builds, compromising production pipelines without touching any protected files.

### Attack Flow

```mermaid
graph LR
    A[PR poisons cache] --> B[Main branch build restores cache]
    B --> C[Cached malicious dep used]
    C --> D[Build compromised]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Gitea | `gitea:3000` | Git server hosting `wl-webapp` with CI caching |
| Registry | `registry:5000` | Local package registry |
| Workstation | (your shell) | Development environment |
