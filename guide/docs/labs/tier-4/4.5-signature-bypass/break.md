# Lab 4.5: Signature Bypass Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Bypass via Key Confusion

### Step 1: Generate an attacker key pair

```bash
cd /app
cosign generate-key-pair --output-key-prefix attacker-cosign
ls /app/attacker-cosign.*
```

### Step 2: Build and push a malicious image

```bash
cat > /tmp/Dockerfile << 'EOF'
FROM alpine:3.18
RUN echo "malicious payload" > /evil.txt
CMD ["cat", "/evil.txt"]
EOF
docker build -t registry:5000/weaklink-app:attacker-signed /tmp/
docker push registry:5000/weaklink-app:attacker-signed
```

### Step 3: Sign it with the attacker key

```bash
cosign sign --key /app/attacker-cosign.key registry:5000/weaklink-app:attacker-signed
```

The image is now legitimately signed, just not by someone you trust.

### Step 4: Verify with the wrong key

```bash
cosign verify --key /app/attacker-cosign.pub registry:5000/weaklink-app:attacker-signed
```

This passes. Nothing is wrong with the cryptography. The failure is in the trust decision: the verifier accepted the attacker's key.

### Step 5: Check that the trusted key rejects it

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:attacker-signed
```

That is the bypass: a system that checks only “is there a valid signature?” can accept a malicious artifact if it does not pin the trusted key or signer identity tightly enough.

!!! info "Related Variants"
    Two other signature failure classes exist, but they are not the mainline attack in this lab:

    - **No enforcement:** an unsigned artifact runs because verification never happens. That is already covered in Lab 4.3.
    - **Replay or rollback:** an old valid signature is reused against a new artifact. Digest-bound signatures like cosign reduce this risk.

> **Checkpoint:** You should have one malicious image, `registry:5000/weaklink-app:attacker-signed`, that verifies with `/app/attacker-cosign.pub` and fails with `/app/cosign.pub`.
