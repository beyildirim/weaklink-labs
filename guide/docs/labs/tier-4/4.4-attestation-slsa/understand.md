# Lab 4.4: Attestation & Provenance (SLSA)

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

## What Build Provenance Proves

### Step 1: Signatures vs. attestations

A **signature** says: "I approve this artifact."
An **attestation** says: "Here are machine-verifiable facts about this artifact."

```
Signature:     "key-holder X approves artifact Y"
Attestation:   "artifact Y was built by CI system Z from source repo A at commit B"
```

### Step 2: SLSA levels

| Level | Requirement | What It Proves |
|-------|-------------|---------------|
| SLSA 1 | Build process exists and produces provenance | "Something built this" |
| SLSA 2 | Build runs on a hosted service, provenance is signed | "A CI system built this" |
| SLSA 3 | Build runs on a hardened, isolated platform | "A tamper-resistant CI built this" |
| SLSA 4 | Hermetic, reproducible build with two-party review | "This was built exactly as specified" |

Most organizations target SLSA 2-3. GitHub Actions with the SLSA generator achieves SLSA 3.

### Step 3: in-toto attestation format

Attestations use the [in-toto Statement](https://in-toto.io/Statement/v0.1) format. Three fields matter:

- **subject**: the artifact this attestation describes (identified by digest)
- **predicate.builder.id**: which CI system produced the build
- **predicate.invocation.configSource**: which source repo and commit triggered the build

You'll see the full structure when you download an attestation in the Defend phase.

### Step 4: Examine the images in the registry

```bash
# Image with provenance
cosign tree registry:5000/weaklink-app:attested

# Image without provenance
cosign tree registry:5000/weaklink-app:no-provenance
```

The attested image has both a signature and an attestation attached. The unattested image has neither.
