# Lab 6.8: Case Study. event-stream / ua-parser-js

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Analyze</span>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Two Different Attack Mechanisms

**Goal:** Walk through the technical details of both attacks.

### event-stream: The targeted dependency injection

```bash
diff /app/event-stream/package-3.3.5.json /app/event-stream/package-3.3.6.json
```

Spot the new dependency: `flatmap-stream` appears in 3.3.6 but not 3.3.5. This is what a lockfile review would have caught.

```bash
cat /app/event-stream/flatmap-stream/package.json
cat /app/event-stream/flatmap-stream/index.min.js
```

Version 0.1.0 was clean. Version 0.1.1 added an encrypted payload in `index.min.js`.

```bash
cat /app/event-stream/analysis/deobfuscated-payload.js
```

The payload was AES-encrypted and only activated if the package's `description` matched the Copay Bitcoin wallet. If matched, it decrypted a second stage that stole wallet private keys. The 2M weekly downloaders were collateral; the attacker only wanted Copay's Bitcoin.

### ua-parser-js: The mass account hijack

```bash
cat /app/ua-parser/malicious-0.7.29/package.json
cat /app/ua-parser/malicious-0.7.29/preinstall.js
```

The three malicious versions contained `preinstall` scripts that on Linux downloaded and started a Monero miner, and on Windows downloaded a credential stealer plus the miner. Every machine that ran `npm install` got infected.

### Comparison

| | event-stream | ua-parser-js |
|---|---|---|
| Attack type | Social engineering | Account compromise |
| Duration | ~2 months | ~4 hours |
| Target | Copay Bitcoin wallet | All users |
| Payload | Encrypted, targeted | Plaintext, mass |
| Detection | Very hard | Moderate (noisy) |

> **Checkpoint:** You should understand the two attack models: targeted dependency injection (event-stream) vs. mass account hijack (ua-parser-js). Examine the deobfuscated payload to confirm the Copay targeting logic.
