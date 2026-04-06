# Lab 3.5: Layer Injection

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

## Catching Layer Injection in Production

The primary signal is **manifest digest change without a corresponding CI build**, or **layer count exceeding the expected baseline**.

**Indicators:**

- Registry `PUT /v2/<repo>/manifests/<tag>` from non-CI IP or identity
- Layer count differs from Dockerfile instruction count plus base image layers
- Signature verification failures during admission control
- Manifest digest for a tag changing outside a CI pipeline run

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Implant Internal Image** | [T1525](https://attack.mitre.org/techniques/T1525/) | Malicious layer injected into trusted image in registry |
| **Command and Scripting Interpreter** | [T1059](https://attack.mitre.org/techniques/T1059/) | Injected layer contains executable reverse shell |

---

**Alert:** "Container image manifest modified outside CI pipeline" or "Image signature verification failed"

Layer injection is hard to spot without baselines. The tag does not change, the application still runs, and `docker inspect` shows nothing obviously wrong.

**Triage steps:**

1. Compare current manifest digest against last known-good from CI
2. Count layers and compare against Dockerfile instruction count plus base image layers
3. Extract each layer with `crane blob` and inspect contents
4. Check registry audit logs for who pushed and when
5. If signed, run `cosign verify`. Failure confirms tampering
6. Quarantine, roll back to last signed digest, investigate registry access

---

## CI Integration

**`.github/workflows/layer-injection-guard.yml`:**

```yaml
name: Layer Injection Guard

on:
  push:
    paths:
      - "Dockerfile*"
  schedule:
    - cron: "0 */6 * * *"

jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install tools
        run: |
          curl -sL https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz \
            | tar xz crane
          sudo mv crane /usr/local/bin/
          curl -sL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 -o /usr/local/bin/cosign
          chmod +x /usr/local/bin/cosign

      - name: Build and push
        run: |
          docker build -t ${{ vars.REGISTRY }}/webapp:${{ github.sha }} .
          docker push ${{ vars.REGISTRY }}/webapp:${{ github.sha }}

      - name: Sign the image
        env:
          COSIGN_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
          COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
        run: |
          DIGEST=$(crane digest ${{ vars.REGISTRY }}/webapp:${{ github.sha }})
          cosign sign --key env://COSIGN_KEY ${{ vars.REGISTRY }}/webapp@$DIGEST

      - name: Record layer baseline
        run: |
          crane manifest ${{ vars.REGISTRY }}/webapp:${{ github.sha }} \
            | jq -r '.layers[].digest' > layer-baseline.txt
          echo "Layer count: $(wc -l < layer-baseline.txt)"

      - name: Upload baseline
        uses: actions/upload-artifact@v4
        with:
          name: layer-baseline
          path: layer-baseline.txt
```

---

## What You Learned

- **Layer injection requires only registry write access.** No build step needed. Attacker patches the manifest JSON and pushes a blob.
- **Unsigned images have no tamper protection.** Without cosign or notation, nothing ties the manifest to a trusted build.
- **Admission control is the enforcement point.** Signing means nothing if the cluster does not verify at deploy time.

## Further Reading

- [cosign: Signing OCI containers](https://github.com/sigstore/cosign)
- [Notation (CNCF Notary Project)](https://notaryproject.dev/)
- [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec/blob/main/spec.md)
