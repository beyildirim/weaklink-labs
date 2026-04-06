# Lab 4.4: Attestation & Provenance (SLSA)

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

## Without Provenance, Origin Is Unknown

### Step 1: Try to verify provenance on the unattested image

```bash
cosign verify-attestation --key /app/cosign.pub \
  --type slsaprovenance \
  registry:5000/weaklink-app:no-provenance
```

Fails. No attestation. No way to know where this image came from.

### Step 2: Build an image locally and push it

```bash
cat > /tmp/Dockerfile << 'EOF'
FROM alpine:3.18
RUN echo "built locally, not in CI" > /app/origin.txt
CMD ["cat", "/app/origin.txt"]
EOF

docker build -t registry:5000/weaklink-app:local-build /tmp/
docker push registry:5000/weaklink-app:local-build
```

### Step 3: Compare the two unattested images

```bash
crane manifest registry:5000/weaklink-app:no-provenance | jq '.mediaType'
crane manifest registry:5000/weaklink-app:local-build | jq '.mediaType'
```

Without provenance, these images are indistinguishable. One may have been built from reviewed source in CI, the other on a developer laptop with modified code. The registry doesn't know.

### Step 4: The insider threat scenario

An insider with registry write access can clone the repo, add a backdoor, build locally, and push with the same tag. Without provenance verification, the replacement is undetectable.

> **Checkpoint:** You should now have two unattested images in the registry (`no-provenance` and `local-build`) and understand why they are indistinguishable without provenance. Run `cosign verify-attestation` on both to confirm they fail.
