#!/bin/bash
# This script seeds the Gitea instance with a sample repository.
# It runs inside the workspace container after Gitea is ready.

set -euo pipefail

GITEA_URL="http://gitea:3000"
ADMIN_USER="weaklink"
ADMIN_PASS="weaklink"
REPO_NAME="web-app"

echo "[*] Waiting for Gitea to be ready..."
for i in $(seq 1 60); do
    if curl -sf "${GITEA_URL}/api/v1/version" > /dev/null 2>&1; then
        echo "[+] Gitea is up."
        break
    fi
    sleep 1
done

# Create the repo via API
echo "[*] Creating repository '${REPO_NAME}'..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
    -H "Content-Type: application/json" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" \
    -d "{
        \"name\": \"${REPO_NAME}\",
        \"description\": \"A simple web application\",
        \"auto_init\": false,
        \"default_branch\": \"main\"
    }" > /dev/null

# Clone and populate
WORKDIR=$(mktemp -d)
cd "${WORKDIR}"
git init
git config user.email "admin@lab.local"
git config user.name "Lab Admin"
git checkout -b main

# Commit 1: Initial project setup
mkdir -p src tests
cat > src/app.py << 'PYEOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Welcome to the Web App!"

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYEOF

cat > requirements.txt << 'PYEOF'
flask==3.0.0
PYEOF

cat > build.sh << 'SHEOF'
#!/bin/bash
# Build script for the web application
echo "=== Building Web App ==="
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Running tests..."
python -m pytest tests/ || true
echo "Build complete!"
SHEOF
chmod +x build.sh

cat > README.md << 'MDEOF'
# Web App

A simple Flask web application.

## Build

```bash
./build.sh
```

## Run

```bash
python src/app.py
```
MDEOF

git add .
git commit -m "Initial project setup

Added Flask app with health endpoint, build script, and requirements."

# Commit 2: Add tests
cat > tests/__init__.py << 'PYEOF'
PYEOF

cat > tests/test_app.py << 'PYEOF'
def test_placeholder():
    """Placeholder test"""
    assert True
PYEOF

git add .
git commit -m "Add test framework

Added pytest test directory with a placeholder test."

# Commit 3: Add configuration
cat > config.yml << 'YMLEOF'
app:
  name: "web-app"
  version: "1.0.0"
  debug: false
  port: 5000

database:
  host: "localhost"
  port: 5432
  name: "webapp_db"
YMLEOF

git add .
git commit -m "Add application configuration

Added config.yml with app and database settings."

# Commit 4: Update app with config loading (bigger commit with more changes)
cat > src/app.py << 'PYEOF'
import os
import yaml
from flask import Flask, jsonify

app = Flask(__name__)

def load_config():
    config_path = os.path.join(os.path.dirname(__file__), "..", "config.yml")
    with open(config_path) as f:
        return yaml.safe_load(f)

@app.route("/")
def home():
    return "Welcome to the Web App v1.0!"

@app.route("/health")
def health():
    return jsonify({"status": "ok", "version": "1.0.0"})

@app.route("/info")
def info():
    config = load_config()
    return jsonify({
        "app": config["app"]["name"],
        "version": config["app"]["version"]
    })

if __name__ == "__main__":
    config = load_config()
    app.run(
        host="0.0.0.0",
        port=config["app"]["port"],
        debug=config["app"]["debug"]
    )
PYEOF

cat > requirements.txt << 'PYEOF'
flask==3.0.0
pyyaml==6.0.1
PYEOF

git add .
git commit -m "Load config from YAML file

Updated app to read settings from config.yml. Added pyyaml dependency.
Added /info endpoint to expose app metadata."

# Commit 5: Create a feature branch with a "security fix"
git checkout -b feature/add-logging
cat > src/logger.py << 'PYEOF'
import logging
import sys

def setup_logging(level="INFO"):
    logger = logging.getLogger("webapp")
    logger.setLevel(getattr(logging, level))
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    )
    logger.addHandler(handler)
    return logger
PYEOF

git add .
git commit -m "Add logging module

Added centralized logging setup for the application."

# Switch back to main
git checkout main

# Push all branches
git remote add origin "${GITEA_URL}/${ADMIN_USER}/${REPO_NAME}.git"
git push -u "http://${ADMIN_USER}:${ADMIN_PASS}@gitea:3000/${ADMIN_USER}/${REPO_NAME}.git" main
git push "http://${ADMIN_USER}:${ADMIN_PASS}@gitea:3000/${ADMIN_USER}/${REPO_NAME}.git" feature/add-logging

echo "[+] Repository seeded successfully!"
echo "    URL: ${GITEA_URL}/${ADMIN_USER}/${REPO_NAME}"
echo "    Branches: main, feature/add-logging"
echo "    Commits on main: 4"

# Clean up
cd /
rm -rf "${WORKDIR}"
