# Lab 0.1: How Version Control Works

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

## Hiding Malicious Code in a Commit

In real attacks, malicious changes are hidden in large pull requests with hundreds of changed lines, making them easy to miss during code review.

### Step 1: Modify the build script

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

Attackers hide malicious lines in big commits. Add a legitimate-looking change too:

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

The commit message says nothing about exfiltrating secrets.

```bash
git push origin main
```

### Step 4: Verify the attack

```bash
export SECRET_API_KEY="sk-prod-abc123-very-secret"
bash build.sh
cat /tmp/stolen-secrets.txt
```

The build script silently stole the secret. In a real CI/CD pipeline, this runs on every build.

**Checkpoint:** You should now have `/tmp/stolen-secrets.txt` with the exfiltrated key, and a malicious `build.sh` commit on `main` buried alongside legitimate utility code.

### Step 5: See how it looks in Git

Open `http://gitea:3000/weaklink/web-app/commits/branch/main` and click the latest commit. The malicious line is in the diff, buried among legitimate changes. In a PR with 500 changed lines, would you have caught it?
