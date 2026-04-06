# Lab 0.4: How CI/CD Works

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

## Securing the CI/CD Pipeline

1. **Restrict Pipeline Modifications:** In Gitea, navigate to Repo Settings -> Branches. Enable branch protection for `main`. Require pull request reviews before merging. This stops attackers from directly pushing modified `.gitea/workflows/` files.

2. **Use Ephemeral Credentials:** Never store static, long-lived secrets (like `DEPLOY_KEY`) in CI. Use OpenID Connect (OIDC) to generate short-lived, scoped tokens dynamically during the build.

3. Revert your malicious commit:
   ```bash
   git revert HEAD --no-edit
   git push
   ```

### Verify the lab

```bash
weaklink verify 0.4
```
