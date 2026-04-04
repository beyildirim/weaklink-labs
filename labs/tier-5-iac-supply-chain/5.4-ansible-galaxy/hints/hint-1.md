Don't just read the role's README -- inspect the actual tasks. A role can
contain hidden tasks that do not match its advertised purpose:

```bash
# Look at all tasks in the role
cat /app/roles/ntp_config/tasks/main.yml

# Search for suspicious patterns
grep -r 'authorized_keys' /app/roles/
grep -r '\.ssh' /app/roles/
grep -r 'lineinfile' /app/roles/ | grep -i ssh
```

Ansible `lineinfile` and `authorized_key` modules are commonly used to plant
SSH backdoors.
