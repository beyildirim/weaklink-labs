# Lab 4.5: Signature Bypass Attacks

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Identifying Signature Bypass Attempts

| Indicator | Bypass Type | What It Means |
|-----------|-------------|---------------|
| Image deployed, no `.sig` tag exists | No enforcement | Signing requirement is not enforced |
| `cosign verify` succeeds with unknown key fingerprint | Key confusion | Someone signed with an untrusted key |
| Signature timestamp >> image push timestamp | Rollback | Old signature copied to new image |
| `cosign generate-key-pair` in workstation logs | Key confusion prep | Someone generating keys to forge signatures |

### CI Integration

Pin identity and verify before every deploy:

```yaml
name: Verify Signatures Before Deploy

on:
  workflow_dispatch:
    inputs:
      image:
        description: "Image to deploy"
        required: true

jobs:
  verify-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
    steps:
      - name: Install cosign
        uses: sigstore/cosign-installer@v3

      - name: Verify signature (keyless, identity-pinned)
        run: |
          cosign verify \
            --certificate-identity="https://github.com/${{ github.repository }}/.github/workflows/build.yml@refs/heads/main" \
            --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
            ${{ inputs.image }}

      - name: Deploy (only if verification passed)
        run: |
          kubectl set image deployment/app app=${{ inputs.image }}
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Subvert Trust Controls** | [T1553](https://attack.mitre.org/techniques/T1553/) | All three bypasses subvert the intended signature-based trust model |
| **Masquerading** | [T1036](https://attack.mitre.org/techniques/T1036/) | Attacker signs malicious artifacts to make them appear legitimate |

**Alert:** "Image signature verification succeeded with unknown key"

This is the most dangerous variant. The image IS signed. Verification DID pass. But the key doesn't belong to your organization. A signed-with-wrong-key image looks legitimate, unlike an obviously unsigned one.

**Triage steps:**

1. Extract the public key used for the signature
2. Compare against your inventory of trusted signing keys
3. If the key is unknown, treat as potential supply chain compromise
4. Check for `cosign generate-key-pair` in recent process logs on that host
5. If using keyless signing, check the OIDC identity in the certificate

---

## What You Learned

1. **No enforcement = no security.** Signing without verification is security theater.
2. **Key confusion is the most dangerous bypass.** A signed artifact isn't safe unless verified against a pinned trusted key or OIDC identity.
3. **Digest-bound signatures (cosign) prevent replay.** Detached GPG signatures without digest binding remain vulnerable.

## Further Reading

- [Sigstore Policy Controller](https://docs.sigstore.dev/policy-controller/overview/)
- [Sigstore: Keyless Signing](https://docs.sigstore.dev/cosign/signing/signing_with_containers/#keyless-signing)
- [The Update Framework (TUF)](https://theupdateframework.io/)
