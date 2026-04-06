# Lab 2.5: Self-Hosted Runner Attacks

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

## Runners Retain State

### Step 1: Examine the runner's filesystem

Examine the runner's workspace. Self-hosted runners persist files between jobs unless explicitly cleaned:

```bash
ls -la /runner/_work/
find /runner/_work/ -type f -name "*.log" 2>/dev/null
```

Self-hosted runners keep their `_work` directory, tool cache, and any files written outside the workspace.

### Step 2: Check what persists between jobs

Check what persists between CI jobs. Artifacts, environment files, cron jobs, and background processes from previous runs may still be active:

```bash
echo "--- Tool cache ---"
ls -la /runner/_work/_tool/

echo "--- Runner environment ---"
cat /runner/.env

echo "--- Cron jobs ---"
crontab -l 2>/dev/null

echo "--- Running processes ---"
ps aux | grep -v grep
```

Anything you install, write, or schedule persists until explicitly cleaned.

### Step 3: Review the workflow configuration

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

The workflow uses `runs-on: self-hosted` and triggers on `pull_request`. Any PR author gets code execution on the persistent runner.

### Step 4: Understand the attack surface

A self-hosted runner processing untrusted PRs gives attackers:

1. **Persistent filesystem access**. write files that survive across builds
2. **Credential theft**. steal tokens, SSH keys, cloud credentials on the machine
3. **Lateral movement**. network access to internal infrastructure
4. **Supply chain persistence**. modify build tools so every future build is compromised
