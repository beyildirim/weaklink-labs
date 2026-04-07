# Hint 2: Digest Pinning

## Phase 3 (DEFEND)

The defense is to reference images by their **digest** instead of their **tag**.

### What is a digest?

A digest is a `sha256:...` hash of the image contents. Unlike tags, digests are immutable. You cannot push a different image with the same digest.

### How to get the digest:

The safe digest was saved during lab setup:

```bash
cat /workspace/safe-digest.txt
```

### How to pull by digest:

```bash
docker pull "registry:5000/webapp@sha256:abc123..."
```

### How to pin in a Dockerfile:

Instead of:
```dockerfile
FROM registry:5000/webapp:latest
```

Write:
```dockerfile
FROM registry:5000/webapp@sha256:abc123...
```

### Creating the defended Dockerfile:

```bash
SAFE_DIGEST=$(cat /workspace/safe-digest.txt)

cat > /workspace/Dockerfile.defended << EOF
FROM registry:5000/webapp@${SAFE_DIGEST}
LABEL security.pinned="true"
LABEL security.verified-digest="${SAFE_DIGEST}"
EOF

# Build it
docker build -t my-defended-app:v1 -f /workspace/Dockerfile.defended /workspace
```

This guarantees that even if `latest` is overwritten in the registry, your Dockerfile always references the exact image you verified.
