To defend, secrets should be scoped to only the steps that need them.

1. Remove secrets from the global `env:` block
2. Add them only to the specific step that requires them
3. Use read-only tokens where possible

Edit `.gitea/workflows/ci.yml`:
- Move `DEPLOY_TOKEN` out of the top-level `env:`
- Add it only to the `deploy` step's `env:` block
- Remove `SECRET_TOKEN` entirely from test/build steps
