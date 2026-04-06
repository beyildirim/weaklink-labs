# Lab 2.5: Self-Hosted Runner Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

## Catching Runner Persistence

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Attacker modifies build infrastructure to compromise future builds |
| **Scheduled Task/Job** | [T1053](https://attack.mitre.org/techniques/T1053/) | Persistence via cron jobs or shell profiles on the runner |

The key signal is filesystem modifications outside the workspace directory during a PR build.

Look for files written to `/runner/_work/_tool/`, `/runner/hooks/`, or runner home directories during PR jobs. Watch for new cron jobs, systemd services, or shell profile modifications. Monitor outbound network connections from the runner between jobs, process trees with children outliving the workflow job, and runner tool cache hash changes.

| Indicator | Type | Description |
|-----------|------|-------------|
| Files in `/runner/_work/_tool/.hidden/` | File | Hidden persistence directory in tool cache |
| Modified `/runner/.bash_profile` | File | Shell profile backdoor |
| New entries in `crontab` | Persistence | Scheduled task persistence |
| Processes surviving job completion | Process | Orphaned malicious processes |
| Outbound connections between jobs | Network | C2 or exfiltration from idle runner |

---

**Alerts you will see:**

- "Runner filesystem modified outside workspace during PR build" (runner audit)
- "New cron job detected on CI runner" (endpoint monitoring)
- "Runner state hash mismatch before job start" (pre-job hook)

**Triage workflow:**

1. **Check what was written**. inspect files created or modified outside the workspace
2. **Check for persistence**. cron jobs, shell profiles, systemd services, startup scripts
3. **Check process tree**. processes that outlived the workflow job?
4. **Identify the trigger**. which PR or workflow run planted the persistence?
5. **If confirmed: quarantine the runner**. take offline, image disk for forensics
6. **Rebuild from scratch**. never trust a compromised runner
7. **Audit all builds**. every build on the compromised runner after the attack is potentially tainted

**False positive rate:** Low. Filesystem modifications outside the workspace during PR builds are inherently suspicious.

---

## CI Integration

**`.github/workflows/runner-integrity.yml`:**

```yaml
name: Runner Integrity Check

on:
  workflow_run:
    workflows: ["*"]
    types: [completed]

jobs:
  verify-runner-state:
    runs-on: self-hosted
    steps:
      - name: Check for persistence mechanisms
        run: |
          echo "--- Checking for unexpected files ---"
          SUSPICIOUS=$(find /runner/_work/_tool -name "*.sh" \
            -newer /runner/.last-verified 2>/dev/null)
          if [ -n "$SUSPICIOUS" ]; then
            echo "::error::New scripts found in tool cache:"
            echo "$SUSPICIOUS"
            exit 1
          fi

          echo "--- Checking crontab ---"
          if crontab -l 2>/dev/null | grep -v '^#' | grep -q .; then
            echo "::error::Unexpected cron jobs found"
            exit 1
          fi

          echo "--- Checking shell profiles ---"
          for f in ~/.bash_profile ~/.bashrc ~/.profile; do
            if [ -f "$f" ]; then
              HASH=$(sha256sum "$f" | cut -d' ' -f1)
              EXPECTED=$(cat "/runner/.baseline/$(basename $f).hash" 2>/dev/null)
              if [ "$HASH" != "$EXPECTED" ]; then
                echo "::error::Shell profile $f has been modified"
                exit 1
              fi
            fi
          done

          touch /runner/.last-verified
          echo "Runner state verified clean."
```

---

## What You Learned

1. **Self-hosted runners retain state**. a single PR can plant backdoors in shell profiles, cron jobs, or the tool cache that persist indefinitely.
2. **Ephemeral runners eliminate persistence**. use `--ephemeral` mode or container isolation so each job starts clean.
3. **Never run untrusted code on self-hosted runners**. route PR builds to ephemeral GitHub-hosted runners.

## Further Reading

- [GitHub: Security hardening for self-hosted runners](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#hardening-for-self-hosted-runners)
- [Adnan Khan: Pwning Self-Hosted GitHub Runners](https://adnanthekhan.com/2023/12/20/one-supply-chain-attack-to-rule-them-all/)
- [Praetorian: Self-Hosted Runner Attacks](https://www.praetorian.com/blog/self-hosted-github-runners-are-backdoors/)
