# Lab 9.1: Cloud Marketplace Poisoning

<div class="lab-meta">
  <span>Phase 1 ~5 min | Phase 2 ~10 min | Phase 3 ~10 min | Phase 4 ~10 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-3/3.1-image-internals.md">Lab 3.1</a></span>
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
