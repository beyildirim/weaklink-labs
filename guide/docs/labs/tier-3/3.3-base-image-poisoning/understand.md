# Lab 3.3: Base Image Poisoning

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

## How Base Images Work

### Step 1: Explore the application Dockerfile

```bash
cat /app/Dockerfile
```

`FROM registry:5000/python-base:3.12` means the app inherits the OS, Python runtime, any additional packages, files, scripts, environment variables, and entrypoint from the base.

### Step 2: Inspect the base image

```bash
docker pull registry:5000/python-base:3.12
docker inspect registry:5000/python-base:3.12 | jq '.[0].Config.Env'
docker history registry:5000/python-base:3.12
```

At first glance, a standard Python base image.

### Step 3: Build and run the app

```bash
docker build -t registry:5000/myapp:latest /app/
docker run --rm registry:5000/myapp:latest
```

The app works. Nothing obviously wrong.

### Step 4: Understand the trust chain

Your Dockerfile only contains your application code. But your image contains everything the base has plus your code. You are implicitly trusting the base image maintainer, the hosting registry, the CI pipeline that built it, and every upstream dependency in it.
