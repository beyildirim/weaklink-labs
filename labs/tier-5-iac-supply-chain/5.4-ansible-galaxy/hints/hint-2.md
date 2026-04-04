The backdoor is in `/app/roles/ntp_config/tasks/main.yml`. One of the tasks
uses the `authorized_key` module to add an attacker's SSH public key to root's
`authorized_keys`.

To fix:

```bash
# Edit the tasks file and remove the malicious task
# The task with 'authorized_key' module should be deleted entirely

# Pin role versions in requirements.yml with checksums:
cat > /app/requirements.yml << 'EOF'
roles:
  - name: ntp_config
    src: ./roles/ntp_config
    version: "1.0.0"
EOF
```

Always review every task in a role before running it. The `ansible-playbook
--check` flag only shows what WOULD change -- it does not protect against
install-time execution in custom modules.
