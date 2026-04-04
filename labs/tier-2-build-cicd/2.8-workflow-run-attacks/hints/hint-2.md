To defend against cross-workflow attacks:

1. **Validate artifact provenance** -- check which workflow and branch
   produced the artifact before using it
2. **Only process artifacts from protected branches** -- skip PR artifacts
3. **Use OIDC tokens** instead of static secrets for deployment
4. **Never execute downloaded artifacts** -- treat them as data only

Apply the defense:

```bash
cp /lab/src/repo/.gitea/workflows/deploy-safe.yml \
   /repos/acme-webapp/.gitea/workflows/deploy.yml
```
