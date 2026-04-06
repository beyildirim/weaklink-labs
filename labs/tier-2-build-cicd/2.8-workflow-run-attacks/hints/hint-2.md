To defend against cross-workflow attacks:

1. **Validate artifact provenance.** Check which workflow and branch
   produced the artifact before using it.
2. **Only process artifacts from protected branches.** Skip PR artifacts.
3. **Use OIDC tokens** instead of static secrets for deployment.
4. **Never execute downloaded artifacts.** Treat them as data only.

Apply the defense:

```bash
cp /lab/src/repo/.gitea/workflows/deploy-safe.yml \
   /repos/wl-webapp/.gitea/workflows/deploy.yml
```
