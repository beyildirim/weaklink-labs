# Lab 3.6: Multi-Stage Build Leaks

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

## How Multi-Stage Builds Work

### Step 1: Examine the Dockerfile

```bash
cat /app/Dockerfile
```

Two stages:

- **`builder`:** Installs build tools, downloads dependencies, compiles. Has access to secrets needed during build.
- **`runtime`:** Minimal base, copies only the compiled artifact, sets entrypoint.

The assumption is that nothing from the builder stage leaks into the final image.

### Step 2: Build the image

```bash
docker build -t registry:5000/myapp:latest /app/
```

### Step 3: Verify the final image looks clean

```bash
docker run --rm registry:5000/myapp:latest
docker run --rm --entrypoint sh registry:5000/myapp:latest -c "ls -la /app/"
```

Only the compiled binary. No source code, no `.env`, no build tools.
