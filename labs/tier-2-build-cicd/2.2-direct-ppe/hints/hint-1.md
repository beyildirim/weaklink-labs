The CI config is in the repository itself. When a PR is created, the
pipeline runs the CI config FROM THE PR BRANCH, not from main.

This means a PR author can modify `.gitea/workflows/ci.yml` to do
anything, including exfiltrating secrets.

Look at the current CI config:

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

Create a branch and modify the `test` step to print environment variables.
