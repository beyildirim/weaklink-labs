# Lab 6.4: Multi-Vector Chained Attack

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

## Executing the Three-Stage Kill Chain

**Goal:** Walk through a complete multi-vector attack from typosquatted package to production compromise.

### Stage 1: Typosquatted package with CI modifier

```bash
cat /app/attacker/typosquatted-package/package.json
cat /app/attacker/typosquatted-package/postinstall.js
```

The `postinstall` script provides legitimate functionality (so the developer does not notice the typo) and quietly modifies `.github/workflows/build-deploy.yml`.

```bash
cd /app/webapp && npm install /app/attacker/typosquatted-package/

diff /app/.github/workflows/build-deploy.yml /app/.github/workflows/build-deploy.yml.bak 2>/dev/null \
    || echo "Check the workflow file for modifications"
cat /app/.github/workflows/build-deploy.yml
```

### Stage 2: Modified CI pipeline

```bash
grep -A 10 "# Added by dependency setup" /app/.github/workflows/build-deploy.yml
cat /app/attacker/ci-payload.sh
```

The payload modifies the application code to include a reverse shell or data exfiltration endpoint. Because it runs in CI, it has access to all CI secrets.

### Stage 3: Backdoored container image

```bash
/app/attacker/simulate-ci-build.sh

docker pull registry:5000/webapp:latest
docker inspect registry:5000/webapp:latest | python3 -m json.tool | head -40
docker run --rm registry:5000/webapp:latest cat /app/server.js
```

The production image now contains a backdoor. It passes image scanning because the backdoor is custom code, not a known CVE.

> **Checkpoint:** You should see the backdoor in the production image's `/app/server.js`. The modified CI workflow should contain an injected step. If either is missing, re-run the stages.
