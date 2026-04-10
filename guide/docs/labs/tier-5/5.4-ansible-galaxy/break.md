# Lab 5.4: Ansible Galaxy and Collection Attacks

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

## A Trojanized Galaxy Role

### Step 1: Examine the suspicious role

```bash
find /app/roles/ntp_config/ -type f
cat /app/roles/ntp_config/tasks/main.yml
```

Looks like a standard NTP role. Check for extra tasks or tasks with misleading names.

### Step 2: Find the backdoor

```bash
grep -n "authorized_key" /app/roles/ntp_config/tasks/main.yml
```

Look for tasks writing to `authorized_keys` or using the `authorized_key` module. The task is likely named something innocent like "Ensure NTP drift file permissions are correct."

### Step 3: Understand the attack

```bash
grep -r "ssh-" /app/roles/ntp_config/
```

The role adds the attacker's SSH public key to root's `authorized_keys` on every host. Ansible runs with `become: true`, so the attacker gets persistent root SSH access across the entire inventory.

### Step 4: See the impact in the role diff

```bash
diff -u /app/vetted/ntp_config/tasks/main.yml /app/roles/ntp_config/tasks/main.yml
```

The diff makes the impact explicit: the suspicious role adds an SSH key task that the reviewed copy does not contain. If this role is trusted in a real playbook run, every managed host receives the attacker's key.

### Step 5: Check for additional persistence

```bash
grep -r "cron\|at\|systemd\|timer\|rc.local" /app/roles/ntp_config/
```

Sophisticated attackers add multiple persistence mechanisms: cron jobs, systemd timers, scripts in `/etc/profile.d/`.

> **Checkpoint:** You should have found the attacker's SSH public key being planted via `authorized_keys` and confirmed the impact with `--check --diff`.
