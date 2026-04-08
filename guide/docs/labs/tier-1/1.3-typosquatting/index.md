# Lab 1.3: Typosquatting

<div class="lab-meta">
  <span>Understand: ~7 min | Break: ~7 min | Defend: ~6 min | Detect: ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution/">Lab 1.1</a></span>
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

A developer installs `reqeusts` instead of `requests`. The package works perfectly. But it also steals their secrets.

### Attack Flow

```mermaid
graph LR
    A[Dev types reqeusts] --> B[pip installs typosquat]
    B --> C[Package wraps real requests]
    C --> D[Also runs exfil code]
    D --> E[Credentials stolen]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| PyPI | `pypi-private:8080` | A private PyPI server with both legitimate and typosquatted packages |
