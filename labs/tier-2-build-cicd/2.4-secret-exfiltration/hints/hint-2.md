To defend against secret exfiltration:

1. Enable **secret masking** -- the CI system replaces secret values
   with `***` in build logs
2. **Never inject secrets into PR builds** -- use a separate workflow
3. **Network egress controls** -- restrict outbound DNS/HTTP from runners
4. **Audit secret access** -- log which jobs accessed which secrets

Apply the hardened config:

```bash
cp /lab/src/repo/.gitea/workflows/ci-hardened.yml \
   /repos/acme-webapp/.gitea/workflows/ci.yml
```
