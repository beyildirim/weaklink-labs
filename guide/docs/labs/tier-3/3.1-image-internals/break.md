# Lab 3.1: Container Image Internals

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

## Hidden Content in Image Layers

### Step 1: Compare two images

Two images are available: `webapp:latest` and `webapp:clean`. They produce identical output:

```bash
docker run --rm registry:5000/webapp:latest
docker run --rm registry:5000/webapp:clean
```

### Step 2: Check the history

```bash
docker history --no-trunc registry:5000/webapp:latest
docker history --no-trunc registry:5000/webapp:clean
```

The `latest` image has extra history entries. One layer copies a file, a subsequent layer deletes it. The file does not appear in the running container's filesystem, but it is still in the image.

### Step 3: Extract all layers

```bash
docker save registry:5000/webapp:latest -o /tmp/webapp.tar
mkdir -p /app/extracted-layers
tar xf /tmp/webapp.tar -C /app/extracted-layers
```

### Step 4: Find the hidden content

```bash
cd /app/extracted-layers
for layer in */layer.tar; do
    echo "=== $layer ==="
    tar tf "$layer" 2>/dev/null | head -20
done
```

One layer contains a file absent from the final filesystem. This is the hidden backdoor, "deleted" by a whiteout file in a later layer but still present in the image data.

### Step 5: Find the whiteout markers

Whiteout files are how container layers "delete" content from earlier layers. A file named `.wh.backdoor.sh` means `backdoor.sh` was deleted in this layer but still exists in an earlier one:

```bash
for layer in */layer.tar; do
    WHITEOUTS=$(tar tf "$layer" 2>/dev/null | grep "\.wh\.")
    if [ -n "$WHITEOUTS" ]; then
        echo "=== Whiteout in: $layer ==="
        echo "$WHITEOUTS"
    fi
done
```

The whiteout filename tells you exactly what was hidden. Strip the `.wh.` prefix to get the original filename.

### Step 6: Extract and read the hidden file

Now find which earlier layer added the original file and extract it:

```bash
HIDDEN_NAME=$(for layer in */layer.tar; do tar tf "$layer" 2>/dev/null | grep "\.wh\."; done | head -1 | sed 's|.*/\.wh\.||')
echo "Looking for: $HIDDEN_NAME"

mkdir -p /tmp/hidden
for layer in */layer.tar; do
    if tar tf "$layer" 2>/dev/null | grep -qF "$HIDDEN_NAME"; then
        echo "Found in: $layer"
        tar xf "$layer" -C /tmp/hidden 2>/dev/null
        find /tmp/hidden -name "$HIDDEN_NAME" -exec cat {} \;
    fi
done
```

### Step 7: Document your findings

```bash
LAYER_HASH=$(for layer in */layer.tar; do tar tf "$layer" 2>/dev/null | grep -l "\.wh\." 2>/dev/null; done | head -1 | cut -d/ -f1)

cat > /app/findings.txt << EOF
Hidden content found in image registry:5000/webapp:latest
File: $HIDDEN_NAME
Added in an early layer, deleted via whiteout in layer $LAYER_HASH.
The file is invisible to docker run but still present in the image data.
Anyone who pulls this image downloads the hidden content.
EOF
cat /app/findings.txt
```

Save the full history output:

```bash
docker history --no-trunc registry:5000/webapp:latest > /app/history-output.txt
```
