# Lab 4.5: Signature Bypass Attacks

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

## Enforce, Pin, Timestamp

### Defense 1: Enforce verification with admission policy

```bash
KEY_DATA=$(sed 's/^/          /' /app/cosign.pub)

cat > /app/enforce-policy.yaml << EOF
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: enforce-trusted-signatures
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - key:
        data: |
${KEY_DATA}
EOF

cat /app/enforce-policy.yaml
```

With this policy applied via Sigstore policy-controller, unsigned and attacker-signed images are both rejected. Only images signed with the trusted key pass admission.

### Defense 2: Pin trusted keys/identities

For key-based signing, hash-pin the trusted public key so a swapped file is detected. Better: use keyless signing and pin the OIDC identity:

```bash
cosign verify \
  --certificate-identity="https://github.com/your-org/your-app/.github/workflows/build.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  $IMAGE
```

Immune to key confusion because the identity is tied to a specific GitHub Actions workflow.

### Defense 3: Include timestamps and expiry

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:signed | jq '.[].optional.Bundle.Payload.integratedTime'
```

Rekor timestamps prove when a signature was created. You can reject signatures older than your policy allows.

### Step 4: Verify the lab

```bash
weaklink verify 4.5
```
