# Lab 2.1: CI/CD Fundamentals

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

## Least-Privilege CI Secrets

### Fix 1: Remove global secrets

```bash
cd /repos/wl-webapp
git checkout main
```

Apply scoped secrets:

```bash
cp /lab/src/repo/.gitea/workflows/ci-secure.yml .gitea/workflows/ci.yml
cat .gitea/workflows/ci.yml
```

Key changes:

1. **No global `env:` block**. secrets are not available to all jobs
2. **Secrets only on the deploy step**. `DEPLOY_TOKEN` scoped to the one step that needs it
3. **Environment protection**. `deploy` job requires the `production` environment with approval rules
4. **Test and build jobs have zero secrets**

### Fix 2: Commit the defense

```bash
git add -A
git commit -m "Scope CI secrets to deploy job only"
git push origin main
```

### Additional defenses

1. **Short-lived OIDC tokens** instead of long-lived API keys
2. **Environment protection rules**: require manual approval before deploy jobs access production secrets
3. **Separate PR and push workflows**: PR builds should never have access to any secrets
