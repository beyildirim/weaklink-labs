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

## Protecting the Pipeline

In the Break phase you pushed a malicious workflow change directly to `main`. The pipeline ran immediately with no review, no approval, and no questions asked. That is the core problem: anyone with push access can rewrite what the pipeline does.

### Step 1: Undo the malicious pipeline change

First, revert the commit that added the secret exfiltration step.

```bash
cd /workspace/ci-demo
git revert HEAD --no-edit
git push origin main
```

Open the **Actions** tab in Gitea (`http://localhost:3000`) and confirm the pipeline runs cleanly without the exfiltration step.

### Step 2: Enable branch protection in Gitea

Now lock down `main` so nobody can push directly to it.

1. Log in to Gitea at `http://localhost:3000` as `weaklink` / `weaklink`
2. Go to the repository: click on **weaklink/ci-demo**
3. Click **Settings** (gear icon, top right of the repo page)
4. Click **Branches** in the left sidebar
5. Under "Branch Protection Rules", click **Add New Rule**
6. Set the following:
   - **Branch name pattern:** `main`
   - Check **Disable Push** (blocks all direct pushes to main)
   - Check **Enable Pull Request reviews**
   - Set **Required approvals:** `1`
7. Click **Save**

This is the same defense you used in Lab 0.1, but here the stakes are higher. In Lab 0.1 you protected source code. Here you are protecting the CI configuration itself, which controls what runs in your build environment and which secrets it can access.

### Step 3: Verify direct push is blocked

Try pushing a change directly to `main`. It should fail.

```bash
cd /workspace/ci-demo

echo "# This push should be rejected" >> app.py
git add app.py
git commit -m "Trying to push directly to main"
git push origin main
```

The push should be **rejected**. This means an attacker can no longer modify `.gitea/workflows/ci.yml` by pushing straight to `main`.

### Step 4: Verify workflow changes require review

The safe path is through a pull request. Create a branch with a harmless change, then open the PR in the Gitea UI.

```bash
cd /workspace/ci-demo
git checkout -b feature/add-comment
echo "# Safe change via PR" >> app.py
git add app.py
git commit -m "Add comment via PR"
git push origin feature/add-comment
```

Then in Gitea:

1. Open `weaklink/ci-demo`
2. Go to **Pull Requests**
3. Click **New Pull Request**
4. Compare `feature/add-comment` into `main`
5. Create the PR
The PR cannot be merged without an approving review. If an attacker tried to sneak a pipeline modification into this PR, a reviewer would catch it before it reaches `main`.

### Step 5: Try the attack again

Switch back to `main` and attempt the same pipeline poisoning from the Break phase, this time through the protected flow.

```bash
cd /workspace/ci-demo
git checkout main
git checkout -b attack/exfiltrate-secrets
```

Edit `.gitea/workflows/ci.yml` and add the exfiltration step from the Break phase inside the `deploy` job, right before `Deploy to staging`:

```yaml
      - name: Exfiltrate secrets
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          echo "EXFILTRATED DEPLOY_KEY=$DEPLOY_KEY"
```

```bash
git add .gitea/workflows/ci.yml
git commit -m "Totally legitimate pipeline update"
git push origin attack/exfiltrate-secrets
```

The push to the *branch* succeeds (branch protection only covers `main`), but merging requires review. A reviewer would see the exfiltration step and reject the PR. The attack is blocked.


### Further Reading

The branch protection rule stops the most basic form of Poisoned Pipeline Execution (PPE), where an attacker pushes directly to the default branch. More advanced defenses include:

- **Ephemeral credentials via OIDC.** Instead of storing long-lived secrets like `DEPLOY_KEY`, the pipeline can request short-lived tokens from your cloud provider at build time. If a secret is never stored, it cannot be stolen from CI configuration. This is covered in later tiers.
- **CODEOWNERS for workflow files.** Some platforms let you require specific reviewers for changes to paths like `.github/workflows/` or `.gitea/workflows/`. This adds a second layer beyond general branch protection.
