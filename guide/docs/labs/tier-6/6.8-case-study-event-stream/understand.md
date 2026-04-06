# Lab 6.8: Case Study. event-stream / ua-parser-js

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step upcoming">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## npm's Trust Model and Maintainer Accounts

**Goal:** Understand how both attacks exploited npm's publishing model.

### The event-stream timeline

| Date | Event |
|------|-------|
| 2018-09 | "right9ctrl" contacts the maintainer, offers to help |
| 2018-09-09 | Maintainer transfers npm publish rights |
| 2018-09-16 | right9ctrl adds `flatmap-stream@0.1.1` as a dependency |
| 2018-10-20 | event-stream@3.3.6 published with the malicious dependency |
| 2018-11-20 | Suspicious code reported on GitHub |

### The ua-parser-js timeline

| Date | Event |
|------|-------|
| 2021-10-22 | Attacker compromises maintainer's npm account |
| 2021-10-22 | Malicious versions 0.7.29, 0.8.0, 1.0.0 published within hours |
| 2021-10-22 | CISA advisory; npm removes malicious versions |

### npm's publishing model

npm's trust model: **whoever has the publish token can publish any version.** No code review, no multi-party approval, no delay. A single compromised token = instant access to every downstream consumer.

### Why maintainers hand off packages

Dominic Tarr (event-stream): "Somebody offered to help. I accepted." npm hosts millions of packages maintained by volunteers with no support structure.
