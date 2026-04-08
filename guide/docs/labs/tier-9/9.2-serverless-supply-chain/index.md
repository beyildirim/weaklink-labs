# Lab 9.2: Serverless Supply Chain

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~10 min | Defend: ~10 min | Detect: ~10 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-1/1.2-dependency-confusion/">Lab 1.2</a></span>
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

Serverless functions depend on: their own code, bundled dependencies, shared Lambda Layers that inject code before your handler runs, the runtime, and the IAM role. Compromise any link, and every invocation is compromised. Two attacks: a malicious Lambda Layer that silently intercepts every invocation, and dependency confusion in a serverless deployment pipeline.

### Attack Flow

```mermaid
graph LR
    A[Malicious Lambda<br>layer published] --> B[Function uses<br>layer]
    B --> C[sitecustomize.py<br>loads at startup]
    C --> D[Layer intercepts<br>every event]
    D --> E[PII and credentials<br>exfiltrated]
```
