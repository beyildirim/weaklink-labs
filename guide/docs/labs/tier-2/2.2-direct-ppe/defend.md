# Lab 2.2: Direct Poisoned Pipeline Execution (PPE)

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

## Protecting the Pipeline

### Fix 1: Separate workflows for push and PR

```bash
cd /repos/wl-webapp
git checkout main
```

```bash
# Main CI -- only runs on push to main, has secrets
cp /lab/src/repo/.gitea/workflows/ci-protected.yml .gitea/workflows/ci.yml

# PR CI -- runs on PRs, has ZERO secrets
cp /lab/src/repo/.gitea/workflows/pr-ci.yml .gitea/workflows/pr-ci.yml

# CODEOWNERS -- require admin review for workflow changes
cp /lab/src/repo/CODEOWNERS CODEOWNERS

cat .gitea/workflows/ci.yml
cat .gitea/workflows/pr-ci.yml
cat CODEOWNERS
```

Key changes:

1. **`ci.yml` triggers ONLY on `push` to main**. never on PRs
2. **`pr-ci.yml` handles PR validation**. runs tests but has zero secrets
3. **CODEOWNERS protects `.gitea/workflows/`**. workflow changes require admin approval
4. **Environment protection** on the deploy job

### Fix 2: Commit and push

```bash
git add -A
git commit -m "Separate PR and push workflows to prevent PPE"
git push origin main
```

### Additional defenses

1. **Fork-based PRs**: run with even more restrictions (no secrets, restricted permissions)
2. **Token scoping**: use `GITHUB_TOKEN` with minimal permissions (`contents: read`) for PR workflows
3. **Branch protection**: require CI to pass before merge, but don't give PR builds secrets

### Step 3: Final verification

```bash
weaklink verify 2.2
```
