# Lab 2.4: Secret Exfiltration from CI

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

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Catching Secret Exfiltration

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Automated Exfiltration** | [T1020](https://attack.mitre.org/techniques/T1020/) | Secrets automatically exfiltrated during CI builds |
| **Unsecured Credentials: Credentials in Files** | [T1552.001](https://attack.mitre.org/techniques/T1552/001/) | Secrets written to build artifacts, logs, and cache files |

Three detection surfaces map to the three channels. Build logs: strings matching known secret patterns (`ghp_`, `AKIA`, `sk-`), base64-encoded strings longer than 40 chars, steps running `env`/`printenv`/`set`. Artifacts: files named `*.log`/`*.env`/`*.txt` with secret patterns, artifact downloads by users who did not trigger the build. DNS: queries from CI runners with subdomains longer than 30 chars, queries to domains not in the allowlist.

---

**Alerts you will see:**

- "Secret pattern detected in build artifact" (artifact scanning)
- "Long DNS query from CI runner" (DNS monitoring)
- "Base64-encoded string in build log from PR build" (log analysis)

**Triage workflow:**

1. **Identify the exfiltration channel**. build logs, artifacts, DNS, or HTTP?
2. **Identify which secrets were exposed**
3. **Rotate immediately**. every secret in scope during the compromised build
4. **Audit secret usage**. check if stolen credentials were used downstream
5. **Block the channel**. restrict egress, enable artifact scanning, enforce masking

**False positive rate:** Varies. Build log detection: medium FP (debug info). DNS exfiltration: low FP (legitimate CI DNS queries are short). Artifact scanning: low FP (secrets in artifacts are always a problem).

---

## CI Integration

**`.github/workflows/secret-leak-scan.yml`:**

```yaml
name: Secret Leak Prevention

on:
  workflow_run:
    # List your workflow names explicitly; wildcards are not supported
    workflows: ["CI", "Build", "Deploy"]
    types: [completed]

jobs:
  scan-artifacts:
    runs-on: ubuntu-latest
    steps:
      - name: Download artifacts from triggering workflow
        uses: actions/download-artifact@v4
        with:
          run-id: ${{ github.event.workflow_run.id }}
          path: /tmp/artifacts/

      - name: Scan for secret patterns
        run: |
          echo "--- Scanning build artifacts for leaked secrets ---"
          LEAKED=0
          while read -r f; do
            if grep -lqE '(ghp_|AKIA|sk-|password=|token=|secret=)' "$f" 2>/dev/null; then
              echo "::error::Secret pattern found in artifact: $f"
              LEAKED=1
            fi
          done < <(find /tmp/artifacts/ -type f)
          if [ "$LEAKED" -eq 1 ]; then
            echo "CRITICAL: Secrets detected in build artifacts. Rotate immediately."
            exit 1
          fi
          echo "PASS: No secrets found in artifacts."
```

---

## What You Learned

1. **Three exfiltration channels**. build logs, artifacts, and DNS/HTTP all leak secrets. Secret masking is bypassable.
2. **Scope secrets to the minimum**. only the deploy step should have deployment credentials.
3. **Network egress controls and artifact scanning** are the last line of defense.

## Further Reading

- [CircleCI Security Incident (2023)](https://circleci.com/blog/jan-4-2023-incident-report/)
- [GitHub: Security hardening. using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Cycode: Secret Scanning in CI/CD](https://cycode.com/blog/cicd-secret-scanning/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
