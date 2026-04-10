# Solution: Lab 5.4

## Key actions

1. Inspect the role's tasks:

```bash
cat /app/roles/ntp_config/tasks/main.yml
```

2. Remove the malicious `authorized_key` task that plants the attacker's SSH key.

3. Pin the reviewed local role source in `requirements.yml`:

```yaml
roles:
  - name: ntp_config
    src: /app/vetted/ntp_config
```

4. Replace the trojanized role with the reviewed local source:

```bash
rm -rf /app/roles/ntp_config
cp -R /app/vetted/ntp_config /app/roles/ntp_config
```

5. Compare the reviewed role to the trojanized one:

```bash
diff -u /app/vetted/ntp_config/tasks/main.yml /app/roles/ntp_config/tasks/main.yml
```

## Why it works

- The `authorized_key` module adds SSH public keys to `~/.ssh/authorized_keys`, giving the attacker persistent access
- This backdoor survives reboots, password changes, and most incident response actions
- Reviewing task files (not just READMEs) catches hidden functionality
- Pinning a reviewed source stops the repo from trusting an unreviewed public role name
- Diffing against a reviewed copy makes the hidden backdoor obvious before the role is trusted again
