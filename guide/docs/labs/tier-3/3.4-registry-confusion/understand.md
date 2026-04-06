# Lab 3.4: Registry Confusion

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

## How Docker Resolves Image Names

### Step 1: Understand name resolution

When you run `docker pull myapp:latest`, Docker:

1. Checks if the name contains a registry hostname (contains `.` or `:`)
2. If not, prepends `docker.io/library/`
3. If registry mirrors are configured, checks mirrors first

```bash
docker pull alpine:latest 2>&1 | head -5
docker pull registry:5000/myapp:latest 2>&1 | head -5
```

### Step 2: Check Docker daemon configuration

```bash
cat /etc/docker/daemon.json
```

The order of registries in `registry-mirrors` or `insecure-registries` matters. Docker checks them in order.

### Step 3: See what each registry has

```bash
crane catalog registry:5000
crane catalog attacker-registry:5000
```

Both have `myapp`. Same name, different registries.

### Step 4: Compare the images

```bash
crane digest registry:5000/myapp:latest
crane digest attacker-registry:5000/myapp:latest
```

Different digests. Different images.

### Step 5: Check the deployment

```bash
cat /app/deploy/deployment.yml
```

Does the image reference include the full registry hostname?
