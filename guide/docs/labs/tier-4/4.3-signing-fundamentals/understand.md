# Lab 4.3: Signing Fundamentals

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

## What Signing Actually Means

**Goal:** Learn the mechanics of cryptographic signing and what it proves.

### Step 1: Generate a cosign key pair

```bash
cd /app
cosign generate-key-pair
```

Enter a password when prompted (or leave blank for the lab). This creates:

- `cosign.key`: private key (used to sign, keep secret)
- `cosign.pub`: public key (used to verify, distribute freely)

### Step 2: Understand what signing proves

A signature proves:

1. **Integrity**: the artifact hasn't been modified since signing
2. **Authenticity**: someone with the private key approved this artifact
3. **Non-repudiation**: the signer can't deny signing it (if key management is solid)

A signature does NOT prove the artifact is safe, does what it claims, or was built from specific source code (that's attestation: [Lab 4.4](../4.4-attestation-slsa/)).

### Step 3: Explore the registry

```bash
crane catalog registry:5000
crane ls registry:5000/weaklink-app
```

Two tags: `signed` and `unsigned`. Both contain the same application code. The registry doesn't care about signatures.

### Step 4: Inspect an image's signatures

```bash
cosign tree registry:5000/weaklink-app:signed
cosign tree registry:5000/weaklink-app:unsigned
```

The signed image has a `.sig` tag. The unsigned image has nothing. Both are valid container images.

### Step 5: Compare GPG and cosign

| Feature | GPG | cosign | Notation |
|---------|-----|--------|----------|
| Key format | PGP keys | ECDSA P-256 / ed25519 | x509 certificates |
| Key management | Manual (keyrings) | Key pairs or keyless (Sigstore) | Certificate chain |
| Signature storage | Detached `.asc` file | OCI registry (alongside image) | OCI registry |
| Verification | `gpg --verify` | `cosign verify` | `notation verify` |
| Keyless option | No | Yes (Sigstore Fulcio + Rekor) | No |

For container images, cosign is the standard. GPG is still common for git commits, tarballs, and Linux packages.
