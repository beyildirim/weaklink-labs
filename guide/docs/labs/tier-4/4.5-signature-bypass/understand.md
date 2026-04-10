# Lab 4.5: Signature Bypass Attacks

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

## When Signing Fails to Protect

### Step 1: The signing trust model

```
Signer (private key) --> Signature --> Verifier (public key) --> Decision (accept/reject)
```

This lab focuses on one failure point:

| Failure | Where It Breaks |
|---------|-----------------|
| Key confusion | The verifier accepts a signature from the wrong public key or identity |

### Step 2: Check the current state

```bash
ls /app/*.pub /app/*.key 2>/dev/null
crane ls registry:5000/weaklink-app
```

Notice there is a trusted key pair for the legitimate signer and space for an attacker to generate a second key pair.

### Step 3: Verify the trusted image works

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:signed
```

This should pass because the image was signed by the trusted key. In the break phase you will sign a malicious image with a different key and see how easy it is to confuse verification when trust is not pinned tightly enough.
