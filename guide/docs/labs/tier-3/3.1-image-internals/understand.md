# Lab 3.1: Container Image Internals

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

## How Container Images Are Built

### Step 1: Pull and inspect an image

```bash
docker pull registry:5000/webapp:latest
docker inspect registry:5000/webapp:latest | jq '.[0].RootFS'
```

`RootFS` shows the layer digests. Each layer is a tarball that adds, modifies, or deletes files on top of the previous layer.

### Step 2: View the build history

```bash
docker history registry:5000/webapp:latest
```

Each Dockerfile instruction that created a layer appears here. Layers with `SIZE` of 0B are metadata-only (`CMD`, `ENV`).

### Step 3: Inspect the manifest with crane

```bash
crane manifest registry:5000/webapp:latest | jq .
```

The manifest contains:

- `mediaType`. the format (OCI or Docker v2)
- `config`. pointer to the config blob (env vars, entrypoint, etc.)
- `layers`. ordered list of layer digests and sizes

### Step 4: Inspect the config blob

```bash
crane config registry:5000/webapp:latest | jq .
```

The config contains runtime metadata: environment variables, entrypoint, working directory, and the full `history` array.

### Step 5: Understand tags vs digests

```bash
# A tag is a mutable pointer
crane digest registry:5000/webapp:latest

# A digest is an immutable content hash
crane manifest registry:5000/webapp@sha256:$(crane digest registry:5000/webapp:latest) | jq .
```

Tags can be overwritten at any time. Digests cannot.

### Step 6: Count the layers

```bash
crane manifest registry:5000/webapp:latest | jq '.layers | length'
```

Remember this number. You will need it to detect when extra layers have been added.
