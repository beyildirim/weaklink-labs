# Lab 4.6: Attestation Forgery

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## What Attestations Claim and How They Are Verified

### Step 1: Examine a legitimate attestation

```bash
cosign download attestation registry:5000/webapp:signed | jq -r '.payload' | base64 -d | jq .
```

An in-toto attestation has three key parts:

- **`_type`**: always `https://in-toto.io/Statement/v0.1`
- **`subject`**: the artifact (identified by digest) this attestation applies to
- **`predicate`**: the claim: who built it, from what source, using which builder

### Step 2: Understand the trust model

```bash
cosign verify-attestation --key cosign.pub registry:5000/webapp:signed | jq .
```

With key-based signing, trust depends entirely on the private key. If the key is compromised or the attacker generates their own key pair, all bets are off.
