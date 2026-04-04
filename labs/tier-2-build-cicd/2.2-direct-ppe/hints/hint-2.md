To defend against Direct PPE:

1. The CI system should NOT execute the CI config from the PR branch.
   Instead, it should always use the CI config from the target branch (main).

2. Add a `.gitea/workflows/pr-ci.yml` that uses read-only secrets
   (or no secrets at all) for PR builds.

3. Mark the `.gitea/workflows/` directory as a CODEOWNERS-protected path
   requiring admin approval for changes.

Apply the protected CI config:

```bash
cp /lab/src/repo/.gitea/workflows/ci-protected.yml \
   /repos/acme-webapp/.gitea/workflows/ci.yml
```
