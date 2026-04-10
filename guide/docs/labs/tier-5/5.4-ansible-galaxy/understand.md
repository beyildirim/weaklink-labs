# Lab 5.4: Ansible Galaxy and Collection Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## How Ansible Galaxy Distributes Automation

### Step 1: Explore the requirements file

```bash
cat /app/requirements.yml
```

This requirement points at a public role name instead of a reviewed internal source. The repo is trusting whatever content came back for that role.

### Step 2: Inspect the role that was already pulled in

```bash
find /app/roles/ntp_config/ -type f | head -20
cat /app/roles/ntp_config/tasks/main.yml
```

This lab seeds the downloaded role locally so you can inspect what a public Galaxy install would have dropped into your automation repo.

### Step 3: Inspect the reviewed local copy

```bash
find /app/vetted/ntp_config/ -type f | head -20
cat /app/vetted/ntp_config/tasks/main.yml
```

This is the clean local copy you will pin to during the defense. It simulates what a reviewed internal mirror or approved vendor snapshot would give you instead of a public role feed.

### Step 4: Understand the trust model

```bash
cat /app/requirements.yml
ls -la /app/roles/ntp_config/
```

The README looks legitimate, but the task file is the truth source. The requirement points at a public-style role name, and the role content is trusted implicitly until someone actually reviews it.
