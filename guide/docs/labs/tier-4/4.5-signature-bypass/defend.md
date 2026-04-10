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

## Pin The Trusted Signer

### Defense 1: Verify with the trusted public key

```bash
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:signed
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:attacker-signed
```

The first command should pass. The second should fail. That is the minimum safe behavior: verification must be anchored to the trusted signer, not any signer.

### Defense 2: Pin the signer identity, not just “a valid signature”

For key-based signing, hash-pin the trusted public key so a swapped file is detected. Better: use keyless signing and pin the OIDC identity:

```bash
cosign verify \
  --certificate-identity="https://github.com/your-org/your-app/.github/workflows/build.yml@refs/heads/main" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  $IMAGE
```

This blocks key confusion because the artifact must come from the exact workflow identity you trust.

### Defense 3: Enforce the trusted signer in admission policy

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

With a policy like this, an attacker-signed image is rejected even though it carries a valid signature. The policy is enforcing *who* may sign, not just whether signing happened at all.
