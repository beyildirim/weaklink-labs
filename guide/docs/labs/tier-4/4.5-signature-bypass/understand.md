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

This chain breaks in three places:

| Bypass | Where It Breaks |
|--------|-----------------|
| No enforcement | Verifier step is missing |
| Key confusion | Wrong public key used for verification |
| Signature rollback | Old valid signature applied to new artifact |

### Step 2: Check the current state

```bash
ls /app/*.pub /app/*.key 2>/dev/null
crane ls registry:5000/weaklink-app
```

### Step 3: Verify the trusted image works

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:signed
```
