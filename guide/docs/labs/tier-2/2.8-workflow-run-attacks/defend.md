# Lab 2.8: Workflow Run & Cross-Workflow Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Securing Cross-Workflow Communication

### Fix 1: Never execute artifact contents

```bash
cd /repos/wl-webapp
git checkout main
```

The `workflow_run` workflow must **never execute, eval, source, or interpret** artifact contents. Treat artifacts as untrusted data.

```bash
cat > .gitea/workflows/deploy-preview.yml << 'EOF'
name: Deploy Preview

on:
  workflow_run:
    workflows: ["PR Build"]
    types: [completed]

permissions:
  deployments: write
  statuses: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.event.workflow_run.conclusion == 'success'
    steps:
      - uses: actions/checkout@v4

      - uses: actions/download-artifact@v4
        with:
          name: build-output
          path: /tmp/build-output
          run-id: ${{ github.event.workflow_run.id }}

      - name: Validate artifact
        run: |
          # Reject executable files
          EXECUTABLES=$(find /tmp/build-output -type f \
            \( -executable -o -name "*.sh" -o -name "*.py" -o -name "*.js" \))
          if [ -n "$EXECUTABLES" ]; then
            echo "::error::Artifact contains executable files:"
            echo "$EXECUTABLES"
            exit 1
          fi

          # Only allow expected file types
          UNEXPECTED=$(find /tmp/build-output -type f \
            ! -name "*.html" ! -name "*.css" ! -name "*.png" \
            ! -name "*.jpg" ! -name "*.svg" ! -name "*.ico")
          if [ -n "$UNEXPECTED" ]; then
            echo "::error::Artifact contains unexpected file types:"
            echo "$UNEXPECTED"
            exit 1
          fi

      # Deploy using the TRUSTED script from main
      - name: Deploy
        run: bash scripts/deploy-preview.sh /tmp/build-output
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
EOF
```

### Fix 2: Use OIDC tokens instead of static secrets

```bash
cat > .gitea/workflows/deploy-preview-oidc.yml << 'EOF'
name: Deploy Preview (OIDC)

on:
  workflow_run:
    workflows: ["PR Build"]
    types: [completed]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.event.workflow_run.conclusion == 'success'
    steps:
      - uses: actions/checkout@v4

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/preview-deploy
          aws-region: eu-west-1

      - name: Deploy static files only
        run: |
          aws s3 sync /tmp/build-output s3://preview-bucket/pr-${{ github.event.workflow_run.id }}
EOF
```

### Fix 3: Verify artifact provenance

```bash
cat > scripts/verify-artifact.sh << 'VERIFY'
#!/bin/bash
ARTIFACT_RUN_ID="$1"
REPO="${GITHUB_REPOSITORY}"

RUN_INFO=$(gh api "/repos/$REPO/actions/runs/$ARTIFACT_RUN_ID" 2>/dev/null)

WORKFLOW_NAME=$(echo "$RUN_INFO" | jq -r '.name')
if [ "$WORKFLOW_NAME" != "PR Build" ]; then
  echo "::error::Artifact from unexpected workflow: $WORKFLOW_NAME"
  exit 1
fi

echo "Provenance check passed."
VERIFY

chmod +x scripts/verify-artifact.sh
```

### Fix 4: Commit and push

```bash
git add -A
git commit -m "Secure workflow_run: validate artifacts, use OIDC, no artifact execution"
git push origin main
```

### Key defenses

1. **Never execute artifact contents**. artifacts are data only; deploy scripts come from `main`
2. **Validate artifact structure**. reject executables, allow only expected file types
3. **Use OIDC tokens**. ephemeral and scoped; eliminates value of secret exfiltration
4. **Minimize `workflow_run` permissions** via `permissions:`

### Step 5: Final verification

```bash
weaklink verify 2.8
```
