# Lab 0.4: How CI/CD Works

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

## Exploring the Pipeline

Focus on trust boundaries as you go. The important question is not just "what does this YAML do?" It is "who can change it, what secrets does it receive, and what happens after a normal push?"

1. Access the Workstation terminal and switch to the lab directory:
   ```bash
   cd /workspace/ci-demo
   ```

2. Inspect the CI workflow configuration:
   ```bash
   cat .gitea/workflows/ci.yml
   ```

3. The critical sections:
   * `on: push` triggers on every push
   * `runs-on: ubuntu-latest` sets the execution environment
   * the deploy job injects `DEPLOY_KEY` into the environment

4. Make a benign change, commit, and push:
   ```bash
   echo "# A benign comment" >> app.py
   git add app.py
   git commit -m "Add comment"
   git push
   ```

5. In the Gitea web interface (`http://localhost:3000`), log in as `weaklink` / `weaklink`, go to the `ci-demo` repo, and click the **Actions** tab. Watch the pipeline run and succeed.

What to notice:

- A normal code push automatically triggers the workflow.
- The deploy job has access to secrets.
- If someone can change the workflow file, they can change what the runner does with those secrets.
