# Lab 0.1: How Version Control Works

> Legacy note: The canonical learner-facing version of this lab lives in the browser guide. Start the platform with `make start`, open the guide, and use the built-in terminal. Treat this README as a secondary local reference.

**Time:** ~25 minutes | **Difficulty:** Beginner | **Prerequisites:** None

Version control (Git) is the foundation of every software supply chain. Every piece of code, every configuration change, every build script lives in a Git repository. If you can compromise what goes into a repo, you control what gets built and deployed.

In this lab you will explore how Git works, then exploit it by hiding malicious code in a commit, then defend against that attack with branch protection.

---

## Environment

This lab runs a **Gitea** server (a lightweight Git hosting platform, similar to GitHub) and a workspace container where you run Git commands.

| Service     | URL / Access                        |
|-------------|-------------------------------------|
| Gitea UI    | http://gitea:3000                   |
| Login       | `weaklink` / `weaklink`             |
| Repository  | `weaklink/web-app`                  |

## Starting the Lab

```bash
make start
```

Then open the guide in your browser and use the built-in terminal for the lab.
All Git commands below run there.

---

## Phase 1: UNDERSTAND. Exploring a Git Repository

**Goal:** Learn how Git stores and tracks changes to code.

### Step 1: Clone the repository

```bash
cd /workspace
git clone http://weaklink:weaklink@gitea:3000/weaklink/web-app.git
cd web-app
```

### Step 2: Look at the commit history

```bash
git log --oneline
```

You should see 4 commits on the `main` branch. Each line shows a short commit ID (like `a1b2c3d`) and the commit message.

**Question:** What was the first thing added to this project? Read the oldest commit message.

### Step 3: See what changed in a specific commit

Pick the commit that says "Load config from YAML file" and inspect it:

```bash
git log --oneline
```

Copy the short commit ID for that commit, then:

```bash
git show <commit-id>
```

Replace `<commit-id>` with the actual ID (e.g., `git show a1b2c3d`).

**Question:** What files were changed in that commit? How many lines were added vs removed?

### Step 4: See the difference between two commits

Compare the first commit to the latest:

```bash
git diff $(git rev-list --max-parents=0 HEAD) HEAD
```

This shows everything that changed from the very first commit to now.

### Step 5: Explore branches

```bash
git branch -a
```

You should see `main` and `remotes/origin/feature/add-logging`. Switch to the feature branch:

```bash
git checkout feature/add-logging
```

```bash
git log --oneline
```

Notice it has one extra commit compared to main. Look at what it adds:

```bash
git diff main..feature/add-logging
```

Switch back to main:

```bash
git checkout main
```

### Step 6: Inspect files

Look at the build script that runs when the project is built:

```bash
cat build.sh
```

This script installs dependencies, runs tests, and produces the build. Anyone who runs `./build.sh` executes whatever is in this file. **Remember this. It matters in Phase 2.**

---

## Phase 2: BREAK. Hiding Malicious Code in a Commit

**Goal:** Demonstrate how an attacker can sneak malicious code into a repository. You will modify the build script to exfiltrate an environment variable, simulating a real supply chain attack.

In real attacks, malicious changes are often hidden in large pull requests with hundreds of changed lines, making them easy to miss during code review.

### Step 1: Modify the build script

Still inside `/workspace/web-app`, edit the build script to add a malicious line:

```bash
cat > build.sh << 'EOF'
#!/bin/bash
# Build script for the web application
echo "=== Building Web App ==="
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Running tests..."
python -m pytest tests/ || true
echo "Build complete!"

# --- The line below is the attack ---
# In a real attack, this would send the secret to an attacker-controlled server.
# Here we just write it to a file to prove the concept.
echo "EXFILTRATED: SECRET_API_KEY=${SECRET_API_KEY:-not_set}" > /tmp/stolen-secrets.txt
EOF
```

### Step 2: Bury it in a larger change

Attackers don't just change one file. They hide malicious lines in big commits. Let's add a legitimate-looking change too:

```bash
cat > src/utils.py << 'EOF'
"""Utility functions for the web app."""

def sanitize_input(text):
    """Remove potentially dangerous characters."""
    return text.replace("<", "&lt;").replace(">", "&gt;")

def format_response(data, status="success"):
    """Standard response format."""
    return {"status": status, "data": data}
EOF
```

### Step 3: Commit and push directly to main

```bash
git add -A
git commit -m "Add utility functions and minor build improvements

Added input sanitization and response formatting helpers.
Small cleanup of build script output formatting."
```

Notice how the commit message says nothing about exfiltrating secrets. It looks like a normal, boring commit.

```bash
git push origin main
```

### Step 4: Verify the attack

Simulate someone running the build:

```bash
export SECRET_API_KEY="sk-prod-abc123-very-secret"
bash build.sh
```

Now check if the secret was stolen:

```bash
cat /tmp/stolen-secrets.txt
```

You should see:
```
EXFILTRATED: SECRET_API_KEY=sk-prod-abc123-very-secret
```

**The build script silently stole a secret.** In a real CI/CD pipeline, this would send secrets to an attacker's server during every build.

### Step 5: See how it looks in the Gitea UI

Open http://gitea:3000/weaklink/web-app/commits/branch/main in your browser.

Click on the latest commit. The malicious line is there in the diff, buried among legitimate code changes. In a real PR with 500 changed lines, would you have caught it?

---

## Phase 3: DEFEND. Branch Protection and Pull Request Reviews

**Goal:** Prevent direct pushes to the main branch. Require that all changes go through a pull request (PR) that must be reviewed.

### Step 1: First, undo the malicious commit

Create a clean revert:

```bash
cd /workspace/web-app
git revert HEAD --no-edit
git push origin main
```

### Step 2: Enable branch protection in Gitea

Open the Gitea UI at http://gitea:3000.

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

Back in the workspace container shell:

```bash
cd /workspace/web-app

cat > evil.txt << 'EOF'
This should not be allowed on main.
EOF

git add evil.txt
git commit -m "Trying to push directly to main"
git push origin main
```

The push should be **rejected** by Gitea. You should see an error message about the branch being protected.

### Step 4: Do it the right way. Create a PR

```bash
git checkout -b feature/add-evil-file
git push origin feature/add-evil-file
```

Now create a pull request via the Gitea API:

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

The PR is created, but it cannot be merged without an approving review. In a real team, another developer would review the changes and either approve or reject them.

**This is the defense:** No one can sneak code into main without at least one other person reviewing it.

### Step 5: Verify with the lab checker

Exit the workspace container:

```bash
exit
```

Run the verification script:

```bash
bash verify.sh
```

---

## What You Learned

| Concept | Why It Matters for Supply Chain Security |
|---------|------------------------------------------|
| **Commits** track every change | Attackers leave traces. Forensics can find malicious commits |
| **Diffs** show exactly what changed | Code review is a critical defense, but only works if people actually read diffs |
| **Direct pushes** bypass review | Without branch protection, anyone with write access can push malicious code |
| **Branch protection** forces review | Requiring PR reviews adds a human checkpoint before code enters the main branch |
| **Commit messages can lie** | A commit message saying "minor cleanup" can contain a backdoor |

## Real-World Examples

- **SolarWinds (2020):** Attackers modified build scripts in a code repository to inject a backdoor into the Orion product. The malicious code was hidden among thousands of lines of legitimate changes.
- **PHP Git Server Compromise (2021):** Attackers pushed malicious commits directly to the PHP source code repository, disguised as typo fixes.

## Further Reading

- [Git Basics (git-scm.com)](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule)
- [OWASP Top 10 CI/CD: Insufficient Flow Control](https://owasp.org/www-project-top-10-ci-cd-security-risks/CICD-SEC-06-Insufficient-Credential-Hygiene)
