# Lab 9.1: Cloud Marketplace Poisoning

<div class="lab-meta">
  <span>Understand: ~5 min | Break: ~10 min | Defend: ~10 min | Detect: ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-3/3.1-image-internals/">Lab 3.1</a></span>
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

Cloud marketplace images are full operating systems deployed into your infrastructure with the publisher's cron jobs, SSH keys, systemd services, and network configurations. If the publisher is malicious or compromised, you just gave an attacker root access. Deploy a "marketplace" container image with three hidden backdoors, find them, and learn to build from scratch instead.

### Attack Flow

```mermaid
graph LR
    A[Attacker publishes<br>marketplace AMI] --> B[Org launches<br>instance]
    B --> C[Backdoor cron<br>phones home]
    C --> D[Pre-installed SSH key<br>gives root access]
    D --> E[Cloud credentials<br>exfiltrated]
```

!!! tip "Related Labs"
    - **Prerequisite:** [3.1 Container Image Internals](../../tier-3/3.1-image-internals/index.md) — Container image internals apply to marketplace container offerings
    - **See also:** [3.4 Registry Confusion](../../tier-3/3.4-registry-confusion/index.md) — Registry confusion is the same concept applied to container registries
    - **See also:** [5.3 Terraform Module and Provider Attacks](../../tier-5/5.3-terraform-module-attacks/index.md) — Terraform module attacks target cloud IaC marketplace equivalents
    - **See also:** [1.2 Dependency Confusion](../../tier-1/1.2-dependency-confusion/index.md) — Dependency confusion applied to cloud marketplace namespaces
