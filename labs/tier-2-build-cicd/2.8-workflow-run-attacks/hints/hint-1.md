The `deploy.yml` workflow triggers via `workflow_run` after the PR CI
completes. It downloads artifacts from the triggering workflow and
executes them -- but it runs in the context of the DEFAULT BRANCH
with write permissions and full secret access.

Look at the workflow chain:

```bash
cat /repos/acme-webapp/.gitea/workflows/ci.yml
cat /repos/acme-webapp/.gitea/workflows/deploy.yml
```

The deploy workflow trusts whatever artifact the CI produced.
A PR can modify the CI to upload a malicious artifact, and the
deploy workflow will execute it with elevated permissions.
