# Lab 0.2: How Package Managers Work

<div class="lab-meta">
  <span>~20 min hands-on | ~5 min reference</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-0/0.1-version-control/">Lab 0.1</a></span>
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

Every modern application is built from dozens or hundreds of third-party packages. When you run `pip install`, you download and execute code written by strangers. Package managers make this convenient, but convenience is the enemy of security.

### Attack Flow

```mermaid
graph LR
    A[Developer runs pip install] -->|Downloads package| B[pip fetches .tar.gz]
    B -->|Extracts archive| C[setup.py executes]
    C -->|Arbitrary Python code| D[Malicious payload runs]
    D --> E[System compromised at install time]
```

## Environment

| Service       | Address                     |
|---------------|-----------------------------|
| Local PyPI    | `pypi-private:8080`         |
| PyPI browser  | `pypi-private:8080/simple/` |

!!! tip "Related Labs"
    - **Prerequisite:** [0.1 How Version Control Works](../0.1-version-control/index.md) — Package manifests live in version-controlled repos
    - **Next:** [1.1 How Dependency Resolution Works](../../tier-1/1.1-dependency-resolution/index.md) — Deep dive into how package managers resolve version ranges
    - **Next:** [0.5 Artifacts & Registries](../0.5-artifacts-registries/index.md) — Where built packages get stored and distributed
    - **See also:** [1.2 Dependency Confusion](../../tier-1/1.2-dependency-confusion/index.md) — What happens when public and private packages collide
