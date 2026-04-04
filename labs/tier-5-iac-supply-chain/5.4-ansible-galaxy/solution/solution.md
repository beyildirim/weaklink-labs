# Solution: Lab 5.4

## Key actions

1. Inspect the role's tasks:

```bash
cat /app/roles/ntp_config/tasks/main.yml
```

2. Remove the malicious `authorized_key` task that plants the attacker's SSH key.

3. Pin role versions in `requirements.yml`:

```yaml
roles:
  - name: ntp_config
    src: ./roles/ntp_config
    version: "1.0.0"
```

4. Verify the playbook only does what it claims:

```bash
ansible-playbook --check -i inventory playbooks/configure-servers.yml
```

## Why it works

- The `authorized_key` module adds SSH public keys to `~/.ssh/authorized_keys`, giving the attacker persistent access
- This backdoor survives reboots, password changes, and most incident response actions
- Reviewing task files (not just READMEs) catches hidden functionality
- Pinning versions prevents the role from silently updating with new malicious tasks
- `--check` mode shows what changes would be made without applying them
