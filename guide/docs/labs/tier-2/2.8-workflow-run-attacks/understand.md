# Lab 2.8: Workflow Run & Cross-Workflow Attacks

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

## workflow_run Privilege Model

### Step 1: Examine the workflow pair

```bash
cd /repos/wl-webapp
cat .gitea/workflows/pr-build.yml
cat .gitea/workflows/deploy-preview.yml
```

The first workflow (`pr-build.yml`) runs on `pull_request`, builds the PR, and uploads an artifact. The second (`deploy-preview.yml`) triggers on `workflow_run` and deploys the artifact with `bash dist/deploy.sh`.

### Step 2: Understand the privilege escalation

| Property | PR Build | Deploy Preview (workflow_run) |
|----------|----------|-------------------------------|
| Trigger | `pull_request` | `workflow_run` |
| Runs on | PR branch | Default branch (`main`) |
| GITHUB_TOKEN | Read-only | **Write access** |
| Secrets | None (fork PR) | **All repository secrets** |

The `workflow_run` trigger runs in the context of the default branch. It does not check out PR code. But it *downloads* and *processes* artifacts created by the untrusted PR workflow.

### Step 3: Identify the trust boundary violation

The artifact bridges unprivileged and privileged contexts. The PR author controls the build output, the artifact is treated as trusted, no integrity check exists, and the deploy workflow has secrets.

### Step 4: Map the full attack chain

```
Fork PR (untrusted)
  -> PR Build workflow (read-only, no secrets)
    -> Upload malicious artifact
      -> workflow_run triggers Deploy Preview
        -> Deploy Preview (WRITE access, ALL secrets)
          -> Downloads malicious artifact
            -> Executes it = RCE with secrets
```

!!! note "Gitea limitation"
    Gitea Actions does not support the `workflow_run` trigger. In this lab, you will construct the attack artifacts manually and understand how the privilege escalation chain would work in GitHub Actions. The defense steps are fully functional.
