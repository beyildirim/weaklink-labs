# Lab 4.4: Attestation & Provenance (SLSA)

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

## Generate and Verify Provenance

### Step 1: Create a provenance attestation

```bash
DIGEST=$(crane digest registry:5000/weaklink-app:attested)
echo "Digest: $DIGEST"
```

Create the provenance document:

```bash
cat > /app/provenance.json << EOF
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [{
    "name": "registry:5000/weaklink-app",
    "digest": {"sha256": "${DIGEST#sha256:}"}
  }],
  "predicate": {
    "builder": {"id": "https://github.com/weaklink-labs/ci-builder"},
    "buildType": "https://github.com/weaklink-labs/build/v1",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/weaklink-labs/app@refs/heads/main",
        "digest": {"sha1": "$(git rev-parse HEAD 2>/dev/null || echo 'abc123')"},
        "entryPoint": ".github/workflows/build.yml"
      }
    }
  }
}
EOF
```

### Step 2: Attach the attestation to the image

```bash
cosign attest --key /app/cosign.key \
  --predicate /app/provenance.json \
  --type slsaprovenance \
  registry:5000/weaklink-app:attested
```

### Step 3: Verify the attestation

```bash
cosign verify-attestation --key /app/cosign.pub \
  --type slsaprovenance \
  registry:5000/weaklink-app:attested
```

Inspect the provenance:

```bash
cosign verify-attestation --key /app/cosign.pub \
  --type slsaprovenance \
  registry:5000/weaklink-app:attested | jq -r '.payload' | base64 -d | jq '.predicate.builder'
```

### Step 4: Confirm the locally-built image has no provenance

```bash
cosign verify-attestation --key /app/cosign.pub \
  --type slsaprovenance \
  registry:5000/weaklink-app:local-build
```

Fails. Now you can distinguish CI-built (attested) from locally-built (unattested).

### Step 5: Create a deployment policy that requires provenance

```bash
cat > /app/provenance-policy.yaml << 'EOF'
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: require-slsa-provenance
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - key:
        data: |
          <COSIGN_PUB_KEY>
      attestations:
        - name: must-have-slsa
          predicateType: "https://slsa.dev/provenance/v0.2"
          policy:
            type: cue
            data: |
              predicate: builder: id: =~"^https://github.com/weaklink-labs/"
EOF
```

This policy requires both a valid signature AND a SLSA provenance attestation from a trusted builder.

### Step 6: Verify the lab

```bash
weaklink verify 4.4
```
