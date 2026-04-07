# Lab 6.9: Case Study. Log4Shell (CVE-2021-44228)

<div class="lab-meta">
  <span>Understand: ~10 min | Analyze: ~10 min | Lessons: ~10 min | Detect: ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution/">Lab 1.1</a></span>
</div>

On December 9, 2021, CVE-2021-44228 was publicly disclosed. By December 10, mass exploitation was underway worldwide. Every security team scrambled to answer: "Do we use Log4j?" Most could not answer quickly because Log4j was a **transitive dependency** buried levels deep. Your application uses Spring Boot, which uses spring-boot-starter-logging, which pulls in log4j-core. The developer never typed "log4j" in their `pom.xml`. A single transitive dependency in a logging library gave attackers unauthenticated RCE on any Java application that logged user-controlled input. CVSS 10.0, affecting an estimated 93% of enterprise cloud environments.

### Attack Flow

```mermaid
graph LR
    A[Attacker sends JNDI<br>string in input] --> B[Application<br>logs the input]
    B --> C[Log4j resolves<br>JNDI lookup]
    C --> D[Connects to<br>attacker LDAP]
    D --> E[Malicious Java<br>class loaded]
    E --> F[Remote code<br>execution]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Vulnerable App | `/app/` | Spring Boot application with transitive Log4j dependency |
| Dependency Analysis | `/app/dependency-tree.txt` | Maven dependency tree showing the Log4j path |
| SBOM | `/app/sbom.json` | CycloneDX SBOM revealing transitive dependencies |
| Detection Tools | `/app/detection/` | Network indicators and detection scripts |

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

!!! tip "Related Labs"
    - **Prerequisite:** [1.1 How Dependency Resolution Works](../../tier-1/1.1-dependency-resolution/index.md) — Dependency resolution explains how Log4j propagated everywhere
    - **See also:** [1.6 Phantom Dependencies](../../tier-1/1.6-phantom-dependencies/index.md) — Log4j was a phantom transitive dependency in most affected projects
    - **See also:** [4.1 What SBOMs Actually Contain](../../tier-4/4.1-sbom-contents/index.md) — SBOMs would have revealed Log4j in dependency trees
    - **See also:** [6.10 Case Study: Equifax Breach](../6.10-case-study-equifax/index.md) — Equifax also involved a known vulnerability in a dependency
