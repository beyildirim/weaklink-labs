# Lab 6.4: Multi-Vector Chained Attack

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

## Layered Defenses Mapped to SLSA Levels

### Layer 1: Package integrity (catches Stage 1)

```bash
cat > /app/webapp/.npmrc << 'EOF'
save-exact=true
package-lock=true
ignore-scripts=true
EOF

npm config set ignore-scripts true --location=project
npm ci --ignore-scripts
```

`ignore-scripts` prevents install-time code execution but breaks packages that need native compilation (esbuild, sharp, node-pre-gyp). Use a scoped approach: run `npm install` in a sandboxed environment first, audit the scripts with `npm pack` and manual review, then install in production. Alternatively, use `npm audit signatures` to verify package provenance.

### Layer 2: CI pipeline integrity (catches Stage 2)

```bash
sha256sum /app/.github/workflows/build-deploy.yml > /app/.github/workflows/build-deploy.yml.sha256

cat > /app/.github/workflows/verify-workflow.yml << 'YMLEOF'
name: Verify Workflow Integrity
on:
  pull_request:
    paths:
      - ".github/workflows/**"
jobs:
  check-workflow-hash:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify workflow file integrity
        run: |
          EXPECTED=$(tail -1 .github/workflows/build-deploy.yml.sha256 | awk '{print $1}')
          ACTUAL=$(sha256sum .github/workflows/build-deploy.yml | awk '{print $1}')
          if [ "$EXPECTED" != "$ACTUAL" ]; then
            echo "::error::Workflow file modified without updating hash."
            exit 1
          fi
YMLEOF
```

### Layer 3: Image provenance (catches Stage 3)

```bash
cat > /app/sign-and-attest.sh << 'SHELLEOF'
#!/bin/bash
IMAGE="$1"
cosign sign --key /app/signing/cosign.key "$IMAGE"
cosign attest --key /app/signing/cosign.key \
    --predicate /app/provenance.json \
    --type slsaprovenance "$IMAGE"
echo "Image signed and provenance attached: $IMAGE"
SHELLEOF
chmod +x /app/sign-and-attest.sh

cat > /app/verify-before-deploy.sh << 'SHELLEOF'
#!/bin/bash
IMAGE="$1"
cosign verify --key /app/signing/cosign.pub "$IMAGE" || exit 1
cosign verify-attestation --key /app/signing/cosign.pub \
    --type slsaprovenance "$IMAGE" || exit 1
echo "PASS: Image signature and provenance verified"
SHELLEOF
chmod +x /app/verify-before-deploy.sh
```

### Layer 4: Runtime enforcement (defense in depth)

```bash
cat > /app/policies/verified-images-only.yaml << 'EOF'
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signature
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: check-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - "registry:5000/*"
          attestors:
            - entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      ...your cosign public key...
                      -----END PUBLIC KEY-----
EOF
kubectl apply -f /app/policies/verified-images-only.yaml
```

### Verify the defense

```bash
weaklink verify 6.4
```
