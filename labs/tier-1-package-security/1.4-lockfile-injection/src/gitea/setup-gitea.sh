#!/bin/bash
#
# Initialize Gitea with a repository and a malicious PR.
# This script runs inside the init container after Gitea is ready.
#

set -euo pipefail

GITEA_URL="http://gitea:3000"
GITEA_USER="developer"
GITEA_PASS="password123"
GITEA_EMAIL="developer@lab.local"
REPO_NAME="webapp"

PYPI_URL="http://pypi-private:8080/simple/"

echo "[*] Waiting for Gitea to be ready..."
for i in $(seq 1 60); do
    if curl -sf "${GITEA_URL}/api/v1/version" > /dev/null 2>&1; then
        echo "[+] Gitea is ready."
        break
    fi
    if [[ $i -eq 60 ]]; then
        echo "[-] Gitea did not become ready in time."
        exit 1
    fi
    sleep 2
done

# Wait a bit more for Gitea to fully initialize
sleep 3

# Register the developer user via the sign-up API
# The first user on a fresh Gitea instance becomes admin
echo "[*] Registering user..."
REGISTER_RESP=$(curl -sf -X POST "${GITEA_URL}/api/v1/user/signup" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"${GITEA_USER}\",
        \"password\": \"${GITEA_PASS}\",
        \"email\": \"${GITEA_EMAIL}\",
        \"full_name\": \"Lab Developer\"
    }" 2>&1 || echo "signup_failed")

if echo "$REGISTER_RESP" | grep -q "signup_failed"; then
    # Gitea versions < 1.22 don't have /api/v1/user/signup
    # Fall back to creating user via the web form
    echo "    Trying web registration..."
    curl -sf -X POST "${GITEA_URL}/user/sign_up" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "user_name=${GITEA_USER}&password=${GITEA_PASS}&retype=${GITEA_PASS}&email=${GITEA_EMAIL}" \
        -L > /dev/null 2>&1 || echo "    (user may already exist)"
fi

echo "[+] User created."

# Configure git
git config --global user.email "$GITEA_EMAIL"
git config --global user.name "$GITEA_USER"
git config --global init.defaultBranch main

# Create the repository via API
echo "[*] Creating repository..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
    -H "Content-Type: application/json" \
    -u "${GITEA_USER}:${GITEA_PASS}" \
    -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false, \"private\": false}" > /dev/null 2>&1 || echo "    (repo may already exist)"

# Initialize the repo locally with the legitimate lockfile
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
git init
git remote add origin "${GITEA_URL}/${GITEA_USER}/${REPO_NAME}.git"

# Create project files
cp /app/project/requirements.in .
cp /app/project/app.py .

# Generate the LEGITIMATE lockfile
echo "[*] Generating legitimate lockfile with pip-compile..."
pip-compile --generate-hashes \
    --index-url "$PYPI_URL" \
    --trusted-host pypi-private \
    requirements.in \
    --output-file requirements.txt 2>/dev/null

# Save the legitimate lockfile for later comparison
cp requirements.txt /app/project/requirements.txt.legitimate

# Also save a copy to the workstation's shared project dir
# (the workstation uses the same image, so /app/project/ exists there too)

# Create the verify-lockfile.sh script
cp /app/project/verify-lockfile.sh .
chmod +x verify-lockfile.sh

# Initial commit on main
git add -A
git commit -m "Initial commit: webapp with flask-utils dependency"
git push -u "http://${GITEA_USER}:${GITEA_PASS}@gitea:3000/${GITEA_USER}/${REPO_NAME}.git" main

echo "[+] Main branch pushed."

# Create the malicious PR branch
git checkout -b update-deps

# Get the hash of the backdoored wheel
echo "[*] Building tampered lockfile..."
BACKDOOR_WHEEL=$(ls /app/packages/backdoor/flask_utils-*.whl 2>/dev/null | head -1)

if [[ -n "$BACKDOOR_WHEEL" ]]; then
    # Calculate the sha256 hash of the backdoored wheel in pip's format
    BACKDOOR_HASH=$(python3 -c "
import hashlib
with open('${BACKDOOR_WHEEL}', 'rb') as f:
    h = hashlib.sha256(f.read()).hexdigest()
    print(h)
")
    echo "    Backdoor hash: sha256:${BACKDOOR_HASH}"

    # Replace the hash in the lockfile with the backdoored one
    sed -i "s|--hash=sha256:[a-f0-9]*|--hash=sha256:${BACKDOOR_HASH}|" requirements.txt
else
    echo "    [!] No backdoor wheel found, using placeholder hash"
    sed -i 's|--hash=sha256:[a-f0-9]*|--hash=sha256:deadbeef00000000000000000000000000000000000000000000000000000000|' requirements.txt
fi

# Save the tampered lockfile
cp requirements.txt /app/project/requirements.txt.tampered

# Commit the tampered lockfile
git add requirements.txt
git commit -m "chore: update flask-utils to latest version

Routine dependency update. Ran pip-compile to refresh the lockfile."

git push "http://${GITEA_USER}:${GITEA_PASS}@gitea:3000/${GITEA_USER}/${REPO_NAME}.git" update-deps

echo "[+] Malicious branch pushed."

# Create the Pull Request
echo "[*] Creating Pull Request..."
PR_RESP=$(curl -sf -X POST "${GITEA_URL}/api/v1/repos/${GITEA_USER}/${REPO_NAME}/pulls" \
    -H "Content-Type: application/json" \
    -u "${GITEA_USER}:${GITEA_PASS}" \
    -d '{
        "title": "chore: update flask-utils to latest version",
        "body": "Routine dependency update.\n\nRan `pip-compile` to refresh the lockfile. No functional changes.\n\n---\n_Auto-generated by dependabot-like bot_",
        "head": "update-deps",
        "base": "main"
    }' 2>&1)

echo "    PR response: ${PR_RESP}" | head -1

# Copy the legitimate lockfile to the workstation container's project dir
# (The workstation can access it since it built from the same image)
# The init and workstation containers share the same /app/project from the image,
# but volumes aren't shared. Instead, the workstation will generate its own lockfile.
# We just need the tampered one available in Gitea.

# Clean up
cd /
rm -rf "$WORK_DIR"

echo ""
echo "[+] Gitea setup complete!"
echo "    Repository: ${GITEA_URL}/${GITEA_USER}/${REPO_NAME}"
echo "    PR #1: chore: update flask-utils to latest version"
echo "    Login: ${GITEA_USER} / ${GITEA_PASS}"
echo ""
