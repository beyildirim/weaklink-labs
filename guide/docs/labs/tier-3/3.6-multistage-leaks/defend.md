# Lab 3.6: Multi-Stage Build Leaks

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

## BuildKit Secrets, Precise COPY, and .dockerignore

### Defense 1: Use BuildKit secret mounts instead of ENV/ARG

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.22 AS builder

# Secret mounted at build time, never written to a layer
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    go build -ldflags "-X main.apiKey=$API_KEY" -o /app/myapp .

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/myapp /app/myapp
ENTRYPOINT ["/app/myapp"]
```

Build with:

```bash
echo "sk-real-secret-key" > /tmp/api_key.txt
DOCKER_BUILDKIT=1 docker build --secret id=api_key,src=/tmp/api_key.txt -t registry:5000/myapp:secure .
```

Verify:

```bash
docker history --no-trunc registry:5000/myapp:secure
crane config registry:5000/myapp:secure | jq '.config.Env'
```

No trace of the API key.

### Defense 2: Use precise COPY instructions

```dockerfile
# Bad: copies everything in /app/
COPY --from=builder /app/ /app/

# Good: copies exactly one file
COPY --from=builder /app/build/myapp /app/myapp
```

### Defense 3: Write a comprehensive .dockerignore

```bash
cat > /app/.dockerignore << 'EOF'
.env
.env.*
*.key
*.pem
credentials.json
config/secrets/
.git/
.github/
node_modules/
__pycache__/
*.pyc
EOF
```

### Defense 4: Scan for secrets in images

```bash
trivy image --scanners secret registry:5000/myapp:latest
```

### Step 5: Verify the lab

```bash
weaklink verify 3.6
```
