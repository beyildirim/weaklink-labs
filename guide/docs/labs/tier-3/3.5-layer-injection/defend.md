# Lab 3.5: Layer Injection

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

## Signing, Verification, and Layer Baselines

### Defense 1: Sign images with cosign

```bash
cosign generate-key-pair

cosign sign --key cosign.key registry:5000/webapp@$MANIFEST_DIGEST
```

Any change to the manifest (including adding a layer) invalidates the signature.

### Defense 2: Verify before deployment

```bash
# Should succeed for the original
cosign verify --key cosign.pub registry:5000/webapp@$MANIFEST_DIGEST

# Should FAIL for the injected image
cosign verify --key cosign.pub registry:5000/webapp@$NEW_DIGEST
```

### Defense 3: Enforce in Kubernetes with admission control

```yaml
apiVersion: policy.sigstore.dev/v1alpha1
kind: ClusterImagePolicy
metadata:
  name: require-cosign-signature
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - key:
        data: |
          -----BEGIN PUBLIC KEY-----
          <your cosign.pub contents>
          -----END PUBLIC KEY-----
```

Unsigned or modified images are rejected at admission time.

### Defense 4: Record layer baselines in CI

```bash
crane manifest registry:5000/webapp:latest | jq -r '.layers[].digest' > /app/layer-baseline.txt
cat /app/layer-baseline.txt
```

Store alongside build artifacts. Any drift means tampering.
