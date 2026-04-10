# Lab 0.1: How Version Control Works

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

## Branch Protection and Pull Request Reviews

### Step 1: Undo the malicious commit

```bash
cd /workspace/web-app
git revert HEAD --no-edit
git push origin main
```

### Step 2: Enable branch protection in Gitea

Open the Gitea UI at `http://localhost:3000`.

1. Log in as `weaklink` / `weaklink`
2. Go to the repository: click on **weaklink/web-app**
3. Click **Settings** (gear icon, top right of the repo page)
4. Click **Branches** in the left sidebar
5. Under "Branch Protection Rules", click **Add New Rule**
6. Set the following:
   - **Branch name pattern:** `main`
   - Check **Disable Push** (this blocks ALL direct pushes)
   - Check **Enable Pull Request reviews**
   - Set **Required approvals:** `1`
7. Click **Save**

### Step 3: Verify direct push is blocked

```bash
cd /workspace/web-app

cat > evil.txt << 'EOF'
This should not be allowed on main.
EOF

git add evil.txt
git commit -m "Trying to push directly to main"
git push origin main
```

The push should be **rejected**.

### Step 4: Do it the right way. Create a PR

```bash
git checkout -b feature/add-evil-file
git push origin feature/add-evil-file
```

```bash
curl -sf -X POST "http://gitea:3000/api/v1/repos/weaklink/web-app/pulls" \
    -H "Content-Type: application/json" \
    -u "weaklink:weaklink" \
    -d '{
        "title": "Add new file",
        "body": "This change adds a new file to the project.",
        "head": "feature/add-evil-file",
        "base": "main"
    }'
```

The PR cannot be merged without an approving review. **This is the defense:** no code enters main without review.
