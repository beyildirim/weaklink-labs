# Lab 3.6: Multi-Stage Build Leaks

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

## Extract Secrets From the Final Image

### Leak 1: Secrets baked into ENV/ARG

```bash
docker history --no-trunc registry:5000/myapp:latest
```

Look for `ENV` or `ARG` instructions. If `ARG` is re-declared in the final stage, or `ENV` is used instead of `ARG`, the value persists.

```bash
crane config registry:5000/myapp:latest | jq '.config.Env'
```

Any `ENV` in the final stage is embedded in the image config as cleartext.

### Leak 2: Secrets in copied file metadata

```bash
docker save registry:5000/myapp:latest -o /tmp/myapp.tar
mkdir -p /tmp/myapp-layers
tar xf /tmp/myapp.tar -C /tmp/myapp-layers

for layer in /tmp/myapp-layers/*/layer.tar; do
    echo "=== $layer ==="
    tar tf "$layer" 2>/dev/null
done
```

Look for `.env` files or config directories accidentally included. Common mistake:

```dockerfile
# Intended: copy only the binary
COPY --from=builder /app/build/myapp /app/myapp

# Actual: copies everything
COPY --from=builder /app/ /app/
```

### Leak 3: Secrets in build context

```bash
cat /app/.dockerignore 2>/dev/null || echo "No .dockerignore found"
```

Without `.dockerignore`, the entire build context is sent to the Docker daemon, including `.env`, `.git/`, and credentials files.

```bash
ls -la /app/
cat /app/.env 2>/dev/null
cat /app/config/credentials.json 2>/dev/null
```

### Step 4: Collect all leaked secrets

```bash
cat > /app/findings.txt << 'EOF'
Multi-Stage Build Leak Analysis
================================

Leak 1 - ENV/ARG in layer history:
  Location: Image config -> .config.Env
  Secret: API_KEY=<extracted-value>
  Cause: ARG/ENV used for build-time secret persists in final image metadata

Leak 2 - Overbroad COPY:
  Location: Layer tarball -> /app/.env or /app/config/
  Secret: <file contents>
  Cause: COPY --from=builder /app/ copied more than just the binary

Leak 3 - Build context:
  Location: Build context sent to daemon
  Secret: .env file or credentials.json
  Cause: No .dockerignore to exclude sensitive files
EOF
```
