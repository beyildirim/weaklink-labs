# Hint 1: Understanding the Pipeline

## Phase 1 (UNDERSTAND)

Look at the CI workflow file in the repository:

```bash
cat .gitea/workflows/ci.yml
```

Key things to notice:
- **`on:`** — What events trigger this pipeline? (push, pull_request, schedule?)
- **`jobs:`** — What runs, and in what order?
- **`secrets:`** — How are secrets referenced? (`${{ secrets.DEPLOY_KEY }}`)
- **`runs-on:`** — Where does this code actually execute?

Every step in the pipeline runs with the permissions of the runner. If you can modify what the pipeline executes, you can access everything the runner can.
