# Lab 1.1: How Dependency Resolution Works

<div class="lab-meta">
  <span>~25 min hands-on | ~10 min reference</span>
  <span class="difficulty intermediate">Intermediate</span>
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

When you run `pip install`, pip resolves an entire dependency tree. **Every supply chain attack exploits something about this process.** Understanding how pip resolves versions across registries is prerequisite to understanding why Alex Birsan's dependency confusion attack affected Microsoft, Apple, and PayPal.

### Attack Flow

```mermaid
graph LR
    A[pip reads config] --> B[Finds extra-index-url]
    B --> C[Queries private + public]
    C --> D[Picks highest version]
    D --> E[Wrong package installed]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Private PyPI | `pypi-private:8080` | Corporate internal PyPI server with legitimate packages |
| Public PyPI | `pypi-public:8080` | Simulated public PyPI (starts with a higher-version fake package) |
