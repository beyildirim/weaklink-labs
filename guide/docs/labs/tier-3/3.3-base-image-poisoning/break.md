# Lab 3.3: Base Image Poisoning

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

## Discovering the Poisoned Base Image

### Step 1: Deep inspect the base image

```bash
docker history --no-trunc registry:5000/python-base:3.12
```

Look for `RUN` or `COPY` commands that do not belong in a standard Python base image.

### Step 2: Look for suspicious files

```bash
docker run --rm registry:5000/python-base:3.12 find /usr/local/bin -type f -newer /usr/local/bin/python3

docker run --rm registry:5000/python-base:3.12 ls -la /docker-entrypoint.d/ 2>/dev/null
docker run --rm registry:5000/python-base:3.12 cat /usr/local/bin/backdoor 2>/dev/null
```

### Step 3: Check if the backdoor is in your app image

```bash
docker run --rm registry:5000/myapp:latest which backdoor 2>/dev/null
docker run --rm registry:5000/myapp:latest cat /usr/local/bin/backdoor 2>/dev/null
```

The backdoor exists in your app image even though your Dockerfile never added it. Inherited from the poisoned base.

### Step 4: Compare with the clean base

```bash
cat /app/clean-base-digest.txt

crane manifest registry:5000/python-base:3.12 | jq '.layers | length'
crane manifest registry:5000/python-base@$(cat /app/clean-base-digest.txt) | jq '.layers | length'
```

The poisoned base has more layers than the clean one.

### Step 5: Scan the base image

```bash
trivy image registry:5000/python-base:3.12
```

### Step 6: Document the finding

```bash
cat > /app/findings.txt << 'EOF'
FINDING: Base image registry:5000/python-base:3.12 is poisoned.
The backdoor binary at /usr/local/bin/backdoor was added in an extra layer.
Every image built FROM this base inherits the backdoor.
Clean base digest: <paste from clean-base-digest.txt>
Poisoned base digest: <paste current digest>
The app Dockerfile was NOT modified. The compromise is entirely in the base.
EOF
```
