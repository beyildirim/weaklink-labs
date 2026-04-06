# Lab 6.8: Case Study. event-stream / ua-parser-js

<div class="lab-meta">
  <span>Understand: ~8 min | Analyze: ~8 min | Lessons: ~10 min | Detect: ~4 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-1/1.6-phantom-dependencies/">Lab 1.6</a></span>
</div>

Two npm incidents that define the dominant supply chain attack vectors. In November 2018, `event-stream` (2M weekly downloads) was discovered with a targeted cryptocurrency-stealing backdoor. A new contributor offered to maintain the abandoned package, gained publish access, then added a dependency containing obfuscated malicious code targeting the Copay Bitcoin wallet. In October 2021, `ua-parser-js` (8M weekly downloads) was hijacked via account compromise. Three malicious versions installed crypto miners and credential stealers on every machine that ran `npm install`. Social engineering maintainer takeover vs. direct account compromise.

### Attack Flow

```mermaid
graph LR
    A[New maintainer<br>gains npm access] --> B[Adds flatmap-stream<br>dependency]
    B --> C[Encrypted payload<br>targets Copay wallet]
    C --> D[Wallet private keys<br>stolen]
    D --> E[Bitcoin<br>exfiltrated]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Package Analysis | `/app/event-stream/` | Reconstructed event-stream and flatmap-stream packages |
| Account Takeover | `/app/ua-parser/` | Analysis of the ua-parser-js account compromise |
| Detection Tools | `/app/detection/` | Scripts for detecting maintainer takeover and malicious updates |
| npm Registry | `npm-registry:4873` | Local Verdaccio registry with attack reconstructions |

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
