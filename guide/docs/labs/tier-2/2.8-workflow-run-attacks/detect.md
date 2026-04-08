# Lab 2.8: Workflow Run & Cross-Workflow Attacks

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

## Catching Cross-Workflow Exploitation

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Exploiting cross-workflow trust to inject malicious code into privileged contexts |
| **Hijack Execution Flow** | [T1574](https://attack.mitre.org/techniques/T1574/) | Replacing trusted artifact with malicious payload to hijack deploy workflow |

The key signal: a `workflow_run` workflow performing unexpected actions (secret access, repository writes, network calls) after processing a PR artifact.

Look for `workflow_run` workflows that download artifacts and then access secrets, repository push events from `workflow_run` contexts, executable files in uploaded artifacts (`.sh`, `.py`, `.js`), outbound HTTP connections not present in previous runs, and artifact size anomalies.

---

**Alerts you will see:**

- "workflow_run job executing files from downloaded artifact" (CI audit)
- "Repository push from workflow_run context" (git webhook monitoring)
- "Executable files detected in uploaded artifact" (artifact scanning)

**Triage workflow:**

1. **Identify the triggering PR**. trace `workflow_run` back to the PR
2. **Inspect the artifact**. download and examine contents for executables or scripts
3. **Check the PR diff**. did the PR modify build scripts or output structure?
4. **Review workflow_run logs**. unexpected commands, network connections, or secret access?
5. **Check for repository changes**. pushes, release creations, or settings changes from workflow_run context?
6. **If confirmed: revert changes, revoke leaked secrets, delete compromised releases**

**False positive rate:** Low. `workflow_run` workflows executing downloaded artifact files is a clear anti-pattern.

---

## CI Integration

**`.github/workflows/artifact-safety.yml`:**

```yaml
name: Artifact Safety Check

on:
  workflow_run:
    # List your workflow names explicitly; wildcards are not supported
    workflows: ["CI", "Build", "Deploy"]
    types: [completed]

jobs:
  audit-artifacts:
    runs-on: ubuntu-latest
    steps:
      - name: Check artifacts for executable content
        uses: actions/github-script@v7
        with:
          script: |
            const runId = context.payload.workflow_run.id;
            const artifacts = await github.rest.actions.listWorkflowRunArtifacts({
              owner: context.repo.owner,
              repo: context.repo.repo,
              run_id: runId,
            });

            for (const artifact of artifacts.data.artifacts) {
              console.log(`Checking artifact: ${artifact.name}`);
              const dangerousExtensions = ['.sh', '.py', '.js', '.rb', '.pl', '.exe', '.bat', '.cmd'];
              console.log(`Artifact ${artifact.name}: size=${artifact.size_in_bytes}`);

              if (artifact.size_in_bytes > 50 * 1024 * 1024) {
                core.warning(`Large artifact detected: ${artifact.name} (${artifact.size_in_bytes} bytes)`);
              }
            }

      - name: Verify no workflow_run executes artifacts
        run: |
          for wf in .github/workflows/*.yml; do
            if grep -q "workflow_run" "$wf"; then
              if grep -q "download-artifact" "$wf" && \
                 grep -Pzo '(?s)download-artifact.*?run:.*?(bash|sh|python|node)' "$wf" 2>/dev/null; then
                echo "::error file=$wf::workflow_run workflow downloads and executes artifacts"
              fi
            fi
          done
```

---

## What You Learned

1. **`workflow_run` always runs on the default branch** with write permissions and all secrets, regardless of the triggering event.
2. **Executing artifact contents is the vulnerability**. a PR author controls what gets built; if `workflow_run` executes it, they get RCE in a privileged context.
3. **Never execute downloaded artifacts**. treat them as untrusted data; run deploy logic from `main`.

## Further Reading

- [GitHub: Events that trigger workflows - workflow_run](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_run)
- [GitHub Security Lab: Keeping your GitHub Actions and workflows secure](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/)
- [Legit Security: GitHub Actions Privilege Escalation](https://www.legitsecurity.com/blog/github-privilege-escalation-vulnerability)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
