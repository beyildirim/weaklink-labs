The backdoor is in `/app/roles/ntp_config/tasks/main.yml`. One of the tasks
uses the `authorized_key` module to add an attacker's SSH public key to root's
`authorized_keys`.

To fix:

```bash
# Edit the tasks file and remove the malicious task
# The task with 'authorized_key' module should be deleted entirely

# Pin the reviewed local copy in requirements.yml:
cat > /app/requirements.yml << 'EOF'
roles:
  - name: ntp_config
    src: /app/vetted/ntp_config
EOF
```

Always review every task in a role before trusting it. A diff against a
reviewed copy makes the hidden SSH key obvious before the role ever reaches
real hosts.
