# Lab 4.7: SBOM Tampering

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Sign SBOMs and Generate Them in CI

### Defense 1: Sign the SBOM with cosign

```bash
cosign generate-key-pair

cosign sign-blob --key cosign.key /app/sbom.json --output-signature /app/sbom.json.sig
```

Verify before consuming:

```bash
cosign verify-blob --key cosign.pub --signature /app/sbom.json.sig /app/sbom.json
```

If the SBOM was modified after signing, verification fails.

### Defense 2: Attach the SBOM to the container image

```bash
cosign attach sbom --sbom /app/sbom.json registry:5000/webapp:latest

cosign verify-attestation --key cosign.pub registry:5000/webapp:latest --type cyclonedx
```

When the SBOM is attached to the image and signed, tampering invalidates the signature.

### Defense 3: Generate SBOMs in CI, never manually

The SBOM should be generated in the same CI pipeline that builds the artifact, signed immediately, and published alongside the artifact.

```yaml
- name: Generate SBOM
  run: syft $IMAGE -o cyclonedx-json > sbom.json

- name: Sign and attach SBOM
  run: |
    cosign attest --predicate sbom.json --type cyclonedx $IMAGE
```

### Defense 4: Cross-validate SBOM against the artifact

```bash
syft registry:5000/webapp:latest -o cyclonedx-json > /app/sbom-fresh.json

diff <(jq -r '.components[].purl' /app/sbom.json | sort) \
     <(jq -r '.components[].purl' /app/sbom-fresh.json | sort)
```

If they disagree, the stored SBOM was tampered with or is stale.

### Step 5: Verify the lab

```bash
weaklink verify 4.7
```
