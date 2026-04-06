# Lab 3.5: Layer Injection

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

## How Layers Compose Into a Filesystem

### Step 1: Inspect the target image

```bash
crane manifest registry:5000/webapp:latest | jq .
```

Each layer digest is a SHA-256 hash of a gzipped tarball. The runtime unpacks them in order, each overlaying the previous.

### Step 2: Record the baseline

```bash
LAYER_COUNT=$(crane manifest registry:5000/webapp:latest | jq '.layers | length')
MANIFEST_DIGEST=$(crane digest registry:5000/webapp:latest)
echo "Baseline: $LAYER_COUNT layers, manifest digest $MANIFEST_DIGEST"
```

### Step 3: Examine a single layer

```bash
crane blob registry:5000/webapp@$(crane manifest registry:5000/webapp:latest | jq -r '.layers[0].digest') | tar tz | head -30
```

Each layer is an independent tarball. Adding one more to the manifest's `layers` array injects arbitrary files.

### Step 4: Verify the image runs clean

```bash
docker pull registry:5000/webapp:latest
docker run --rm registry:5000/webapp:latest
```
