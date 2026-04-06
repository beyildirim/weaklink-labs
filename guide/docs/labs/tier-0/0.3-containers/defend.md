# Lab 0.3: How Containers Work

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

## Digest Pinning

### Step 1: Get the safe image's digest

```bash
SAFE_DIGEST=$(cat /workspace/safe-digest.txt)
echo "Safe image digest: ${SAFE_DIGEST}"
```

### Step 2: Pull by digest

```bash
docker pull "registry:5000/webapp@${SAFE_DIGEST}"
```

The digest is immutable. It does not matter that `latest` now points to the backdoored image.

### Step 3: Verify it is safe

```bash
docker run -d --name check-digest -p 8001:8000 "registry:5000/webapp@${SAFE_DIGEST}"
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-digest && docker rm check-digest
```

`backdoor: false`. Digest pinning works.

### Step 4: Create a Dockerfile with digest pinning

```bash
cat > /workspace/Dockerfile.defended << EOF
# DEFENDED: Pinned by digest, not by tag.
# This guarantees we always get the exact image we verified,
# even if someone overwrites the tag in the registry.
FROM registry:5000/webapp@${SAFE_DIGEST}

# Any additional customization goes here
LABEL security.pinned="true"
LABEL security.verified-digest="${SAFE_DIGEST}"
EOF

cat /workspace/Dockerfile.defended
```

### Step 5: Build and test the defended image

```bash
docker build -t my-defended-app:v1 -f /workspace/Dockerfile.defended /workspace
docker run -d --name check-defended -p 8001:8000 my-defended-app:v1
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-defended && docker rm check-defended
```

`backdoor: false`. The Dockerfile is pinned to the safe digest regardless of what `latest` points to.

### Step 6: Verify the lab

```bash
weaklink verify 0.3
```
