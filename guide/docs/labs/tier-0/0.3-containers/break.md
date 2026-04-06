# Lab 0.3: How Containers Work

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

## Mutable Tags and Image Substitution

### Step 1: Verify the current image is safe

```bash
docker run -d --name check-safe -p 8001:8000 registry:5000/webapp:latest
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-safe && docker rm check-safe
```

The `backdoor` field should be `false`.

### Step 2: Simulate an attacker overwriting the tag

An attacker with registry or CI/CD access builds a backdoored image and pushes it with the same `latest` tag:

```bash
cd /lab/src/backdoor
docker build -t registry:5000/webapp:latest .
docker push registry:5000/webapp:latest
```

The `latest` tag now points to the **backdoored image**. The registry accepted it without complaint.

### Step 3: Pull "latest" again. You get the backdoor

```bash
docker rmi registry:5000/webapp:latest 2>/dev/null
docker pull registry:5000/webapp:latest
```

### Step 4: Run it and see the backdoor

```bash
docker run -d --name check-backdoor -p 8001:8000 registry:5000/webapp:latest
sleep 2
curl -s http://localhost:8001/health | jq .
```

The `backdoor` field is now `true`. The backdoored image also has a hidden `/debug` endpoint that leaks environment variables:

```bash
curl -s http://localhost:8001/debug | jq .
```

```bash
docker exec check-backdoor cat /tmp/backdoor-active
```

**The container looks identical from the outside** (same homepage, same version string) but runs completely different code.

**Checkpoint:** You should now have the backdoored image running with `backdoor: true` in `/health` and a `/debug` endpoint leaking environment variables. The `latest` tag in the registry points to the attacker's image.

Clean up:

```bash
docker stop check-backdoor && docker rm check-backdoor
```

### Step 5: Notice the tag `1.0.0` is still safe

```bash
docker pull registry:5000/webapp:1.0.0
docker run -d --name check-pinned -p 8001:8000 registry:5000/webapp:1.0.0
sleep 2
curl -s http://localhost:8001/health | jq .
docker stop check-pinned && docker rm check-pinned
```

The `backdoor` field is `false`. The attacker only overwrote `latest`, not `1.0.0`. But version tags are also mutable. **The only immutable reference is the digest.**
