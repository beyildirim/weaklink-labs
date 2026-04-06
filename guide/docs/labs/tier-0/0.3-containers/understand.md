# Lab 0.3: How Containers Work

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

## Building and Inspecting Container Images

### Step 1: Look at the Dockerfile

```bash
cat /lab/src/app/Dockerfile
```

A Dockerfile is a recipe for building a container image. Each line is an instruction:

| Instruction | What It Does |
|-------------|--------------|
| `FROM python:3.11-slim` | Start from an existing image (the "base image") |
| `WORKDIR /app` | Set the working directory inside the container |
| `COPY app.py .` | Copy a file from your machine into the image |
| `EXPOSE 8000` | Document which port the app uses |
| `CMD ["python", "app.py"]` | Define what runs when the container starts |

### Step 2: Build the image

```bash
cd /lab/src/app
docker build -t my-webapp:v1 .
```

Each Dockerfile instruction creates a **layer**. Layers stack to form the final image.

### Step 3: See the layers

```bash
docker history my-webapp:v1
```

### Step 4: Run the container

```bash
docker run -d --name test-app -p 8000:8000 my-webapp:v1
curl -s http://localhost:8000/health | jq .
```

You should see `"backdoor": false`. Stop it:

```bash
docker stop test-app && docker rm test-app
```

### Step 5: Check the local registry

```bash
curl -s http://registry:5000/v2/webapp/tags/list | jq .
```

Tags `latest` and `1.0.0` both point to the same safe image.

### Step 6: Pull and note the digest

```bash
docker pull registry:5000/webapp:latest
cat /workspace/safe-digest.txt
```

**This digest matters in Phase 3.**
