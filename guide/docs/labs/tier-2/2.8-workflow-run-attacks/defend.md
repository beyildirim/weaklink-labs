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
cp /lab/src/repo/.gitea/workflows/deploy-safe.yml .gitea/workflows/deploy.yml
cat .gitea/workflows/deploy.yml
```

The hardened workflow keeps the same file the seeded repo actually uses, but changes its trust model:

1. **Reject PR-triggered runs**
2. **Require `head_branch == main`**
3. **Do not execute `dist/deploy.sh` from the artifact**
4. **Use environment protection for deploy**

### Fix 2: Use OIDC tokens instead of static secrets

`workflow_run` is still conceptual in Gitea, so keep this as a design improvement rather than an in-lab requirement:

- Prefer OIDC tokens over static secrets
- Minimize `workflow_run` permissions
- Use a trusted deploy script from `main`, never from the artifact

### Fix 3: Verify artifact provenance

### Fix 3: Commit and push

```bash
git add -A
git commit -m "Secure workflow_run: reject PR artifacts and never execute them"
git push origin main
```

### Key defenses

1. **Never execute artifact contents**. artifacts are data only; deploy scripts come from `main`
2. **Validate artifact structure**. reject executables, allow only expected file types
3. **Use OIDC tokens**. ephemeral and scoped; eliminates value of secret exfiltration
4. **Minimize `workflow_run` permissions** via `permissions:`
