To defend against secret exfiltration:

1. Enable **secret masking** so the CI system replaces secret values
   with `***` in build logs.
2. **Never inject secrets into PR builds.** Use a separate workflow.
3. **Network egress controls.** Restrict outbound DNS/HTTP from runners.
4. **Audit secret access.** Log which jobs accessed which secrets.

Apply the hardened config:

```bash
cp /lab/src/repo/.gitea/workflows/ci-hardened.yml \
   /repos/wl-webapp/.gitea/workflows/ci.yml
```
