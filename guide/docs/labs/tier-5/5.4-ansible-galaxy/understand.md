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

Some entries specify a version, others do not. Without a version pin, `ansible-galaxy` installs the latest available.

### Step 2: See what is available on the Galaxy server

```bash
curl -s http://galaxy-server:8080/api/v1/roles/ | python3 -m json.tool
curl -s http://galaxy-server:8080/api/v2/collections/ | python3 -m json.tool
```

Role names follow `namespace.rolename`, but namespace squatting is possible. No verification that a namespace owner controls the corresponding GitHub organization.

### Step 3: Install roles from requirements

```bash
ansible-galaxy install -r /app/requirements.yml -p /app/roles/ --force
```

Ansible downloads each role as a tarball and extracts it. No integrity check beyond basic archive extraction.

### Step 4: Examine a legitimate role

```bash
find /app/roles/ntp_config/ -type f | head -20
cat /app/roles/ntp_config/tasks/main.yml
```

Standard role: install NTP, deploy config, enable service.

### Step 5: Understand the trust model

```bash
ls -la /app/roles/ntp_config/
# No .sha256, no .sig, no .asc file
```

No built-in mechanism for role signing or content verification. The only trust signals are namespace name and download count, both manipulable.
