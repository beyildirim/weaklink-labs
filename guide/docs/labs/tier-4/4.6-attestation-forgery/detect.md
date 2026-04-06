# Lab 4.6: Attestation Forgery

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

## Spotting Forged or Suspicious Attestations

| Indicator | What It Means |
|-----------|---------------|
| `cosign attest` from a developer workstation IP | Attestations created outside CI |
| Missing Rekor log entry for a signed artifact | Signing happened offline or with `--no-tlog-upload` |
| OIDC issuer mismatch in attestation certificate | Signed by a different identity provider than expected |
| `builder.id` claims GitHub Actions but OIDC issuer is not `token.actions.githubusercontent.com` | Builder identity is forged |
| Multiple attestations for the same digest signed by different identities | Conflicting provenance claims |

### CI Integration

Verify attestation OIDC identity as a deployment gate:

```yaml
name: Attestation Verification Gate

on:
  workflow_dispatch:
    inputs:
      image:
        description: "Image reference to verify"
        required: true

jobs:
  verify-attestation:
    runs-on: ubuntu-latest
    steps:
      - name: Verify attestation with OIDC identity
        env:
          IMAGE: ${{ inputs.image }}
        run: |
          cosign verify-attestation \
            --certificate-oidc-issuer https://token.actions.githubusercontent.com \
            --certificate-identity-regexp "https://github.com/${{ github.repository_owner }}/" \
            --type slsaprovenance \
            "$IMAGE"

      - name: Verify SLSA provenance
        env:
          IMAGE: ${{ inputs.image }}
        run: |
          slsa-verifier verify-image "$IMAGE" \
            --source-uri "github.com/${{ github.repository }}" \
            --builder-id "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml"
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Forge Web Credentials** | [T1606](https://attack.mitre.org/techniques/T1606/) | Attacker creates a valid signature that impersonates a trusted builder identity |
| **Subvert Trust Controls: Code Signing** | [T1553.002](https://attack.mitre.org/techniques/T1553/002/) | Forged attestation bypasses signature-based trust controls that gate deployment |

**Alert:** "Attestation signer identity does not match expected builder" or "Attestation missing transparency log entry"

Attestation forgery bypasses the strongest verification controls. If your policy is "only deploy signed and attested artifacts," an attacker who can forge attestations has carte blanche.

**Triage steps:**

1. Check the OIDC issuer and signer identity against the expected CI system
2. Search Rekor for the signing event. If absent, the attestation may have been created offline
3. Compare the attestation's `configSource.uri` against the actual repository
4. Check the timestamp against CI pipeline execution logs
5. If forgery is confirmed, quarantine the artifact, revoke the signing key, and audit all artifacts signed by the same identity

---

## What You Learned

1. **Key-based attestation signing is only as strong as the key.** An attacker with their own key pair can forge any attestation and pass verification.
2. **Keyless signing with Sigstore binds identity to attestations.** The OIDC token proves who actually signed, not just that a valid key was used.
3. **Transparency logs make forgery detectable.** Missing or inconsistent Rekor entries are a red flag.

## Further Reading

- [Sigstore: Software signing for everyone](https://www.sigstore.dev/)
- [SLSA Provenance Specification](https://slsa.dev/provenance/v1)
- [Rekor Transparency Log](https://docs.sigstore.dev/logging/overview/)
