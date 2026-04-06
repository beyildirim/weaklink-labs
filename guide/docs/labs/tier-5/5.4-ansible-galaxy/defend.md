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

## Pinning, Reviewing, and Privatizing Galaxy Content

### Fix 1: Pin exact versions with checksums

```bash
cat > /app/requirements.yml << 'EOF'
---
roles:
  - name: ntp_config
    version: "2.1.0"
    src: http://galaxy-server:8080/download/ntp_config-2.1.0.tar.gz

collections:
  - name: community.general
    version: "8.3.0"
EOF
```

### Fix 2: Generate and verify checksums

```bash
find /app/roles/ -name "*.tar.gz" -exec sha256sum {} \; > /app/roles/checksums.sha256
sha256sum -c /app/roles/checksums.sha256
```

### Fix 3: Review roles before installation

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

/app/review_role.sh /app/roles/ntp_hardened/
```

### Fix 4: Use a private Automation Hub

```bash
cat > /app/ansible.cfg << 'EOF'
[galaxy]
server_list = private_hub

[galaxy_server.private_hub]
url=http://galaxy-server:8080/
validate_certs=True
EOF
```

Removes public Galaxy from the server list. All roles must be vetted and uploaded to the private hub.

### Fix 5: Remove the trojanized role

```bash
rm -rf /app/roles/ntp_hardened/
ansible-galaxy install -r /app/requirements.yml -p /app/roles/ --force
```

### Verify the defense

```bash
weaklink verify 5.4
```
