# Lab 6.4: Multi-Vector Chained Attack

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

## How Supply Chain Attacks Chain Together

**Goal:** Map how individual attack techniques from earlier labs combine into a multi-stage kill chain.

### Step 1: Review the application and its pipeline

```bash
cat /app/webapp/package.json
cat /app/webapp/server.js
cat /app/.github/workflows/build-deploy.yml

kubectl get deployments -n production
kubectl get pods -n production
```

### Step 2: Identify controls at each boundary

```bash
# Boundary 1: npm install
cat /app/webapp/package-lock.json | head -20
ls /app/webapp/.npmrc 2>/dev/null

# Boundary 2: CI pipeline
grep -A 5 "security\|scan\|check\|verify" /app/.github/workflows/build-deploy.yml

# Boundary 3: Container registry
curl -s http://registry:5000/v2/_catalog | python3 -m json.tool

# Boundary 4: Kubernetes
kubectl get validatingwebhookconfigurations 2>/dev/null
```

Note which boundaries have controls and which do not.

### Step 3: Understand the kill chain model

The attacker's plan:

1. **Stage 1 (Package):** Publish a typosquatted npm package
2. **Stage 2 (CI):** The package's postinstall script modifies the CI workflow
3. **Stage 3 (Image):** The modified CI workflow injects a backdoor into the Docker image

Each stage passes the controls designed for that layer. The package scanner does not check for CI modifications. The CI audit does not scan Docker images. The image scanner does not know the image was built by a compromised pipeline.
