# Lab 4.6: Attestation Forgery

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Keyless Signing and Transparency Logs

### Defense 1: Keyless signing with Sigstore

Instead of managing key pairs, use Sigstore's keyless flow. The signer authenticates via OIDC, and the signing event is logged in Rekor.

```bash
COSIGN_EXPERIMENTAL=1 cosign attest --predicate /tmp/attestation.json \
  --type slsaprovenance registry:5000/webapp:latest
```

The resulting attestation contains the OIDC issuer, the workflow identity, and a Rekor transparency log entry with a timestamp.

### Defense 2: Verify builder identity, not just signature validity

```bash
cosign verify-attestation \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "https://github.com/org/webapp/" \
  registry:5000/webapp:latest
```

This checks: (1) valid signature, (2) OIDC token came from GitHub Actions, (3) workflow identity matches expected repository. An attacker cannot forge this because they cannot obtain a valid OIDC token from GitHub Actions for your repository.

### Defense 3: Check the transparency log

```bash
rekor-cli search --sha $MALICIOUS_DIGEST

# Use the UUID from the search output (first column)
ENTRY_UUID=$(rekor-cli search --sha $MALICIOUS_DIGEST --format json | jq -r '.[0]')
rekor-cli get --uuid $ENTRY_UUID | jq .
```

Rekor provides public auditability, non-repudiation, and tamper detection (Merkle tree).

### Defense 4: SLSA verifier with source pinning

```bash
slsa-verifier verify-image registry:5000/webapp:latest \
  --source-uri github.com/org/webapp \
  --source-tag v1.2.3 \
  --builder-id https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml
```

Validates the entire provenance chain: builder identity, source repository, source ref, and build configuration.
