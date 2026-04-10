# Lab 5.4: Ansible Galaxy and Collection Attacks

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

## Pinning, Reviewing, and Replacing with a Reviewed Local Copy

### Fix 1: Pin the reviewed local copy

```bash
cat > /app/requirements.yml << 'EOF'
---
roles:
  - name: ntp_config
    src: /app/vetted/ntp_config
EOF
```

### Fix 2: Review roles before installation

```bash
cat > /app/review_role.sh << 'SHELLEOF'
#!/bin/bash
ROLE_PATH="$1"
echo "=== Reviewing role: $ROLE_PATH ==="

echo -e "\n--- Checking for SSH key manipulation ---"
grep -rn "authorized_key\|ssh-rsa\|ssh-ed25519\|\.ssh/" "$ROLE_PATH" || echo "CLEAN"

echo -e "\n--- Checking for user creation ---"
grep -rn "user:\|useradd\|adduser" "$ROLE_PATH" || echo "CLEAN"

echo -e "\n--- Checking for cron/persistence ---"
grep -rn "cron\|at \|systemd.*timer\|rc.local\|profile\.d" "$ROLE_PATH" || echo "CLEAN"

echo -e "\n--- Checking for network callbacks ---"
grep -rn "curl\|wget\|nc \|ncat\|/dev/tcp\|raw_socket" "$ROLE_PATH" || echo "CLEAN"

echo -e "\n=== Review complete ==="
SHELLEOF
chmod +x /app/review_role.sh

/app/review_role.sh /app/vetted/ntp_config/
```

### Fix 3: Replace the trojanized role with the reviewed copy

```bash
rm -rf /app/roles/ntp_config/
cp -R /app/vetted/ntp_config /app/roles/ntp_config
```

This keeps the workflow simple for the lab: you review a clean local copy and replace the bad role with that reviewed source. In a real environment, the same idea would usually be implemented with an internal Galaxy mirror or artifact repository.
