# Lab 4.3: Signing Fundamentals

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

## Identifying Unsigned Deployments

**What to look for:**

- Kubernetes audit logs showing image deployments without cosign signatures
- Admission controller deny events for unsigned images
- Images pulled from registries lacking `.sig` tags
- cosign verification failures in CI/CD pipeline logs

| Indicator | What It Means |
|-----------|---------------|
| `admission.k8s.io/deny` with "signature" in message | Policy controller rejected unsigned image |
| Pod creation for image without `.sig` tag | Image was never signed |
| `cosign verify` exit code != 0 in CI logs | Signature verification failed |
| Image digest changes without new signature | Image modified after signing (or re-tagged) |

### CI Integration

Add signature verification as a gate before deployment:

```yaml
- name: Verify image signature before deploy
  run: |
    cosign verify \
      --certificate-identity="https://github.com/${{ github.repository }}/.github/workflows/build.yml@refs/heads/main" \
      --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
      ${{ env.IMAGE }}
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Subvert Trust Controls** | [T1553](https://attack.mitre.org/techniques/T1553/) | Deploying unsigned artifacts bypasses the intended trust chain |
| **Obtain Capabilities: Code Signing Certificates** | [T1588](https://attack.mitre.org/techniques/T1588/) | Attackers may steal signing keys to sign malicious artifacts |

**Alert you will see:** "Unsigned container image deployed to production cluster"

Without signing enforcement, an attacker with registry write access can push any image. There's no cryptographic barrier between "push to registry" and "running in production." Signing + enforcement creates that barrier.

**Triage steps:**

1. Check who pushed the image (`crane manifest` + registry access logs)
2. Verify if the image was ever signed (`cosign tree <image>`)
3. Check if this is a new image or a re-tag of an existing one
4. If unsigned and running in production, treat as potential supply chain compromise
5. If the admission controller should have blocked it, investigate the policy gap

---

## What You Learned

1. **Signing creates a cryptographic link between a key holder and an artifact**: it proves integrity, authenticity, and non-repudiation.
2. **Unsigned images are accepted everywhere by default**: signing without enforcement is meaningless.
3. **Keyless signing (Sigstore) ties signatures to CI identities instead of static keys**: harder to compromise than managing key pairs.

## Further Reading

- [Sigstore: cosign](https://docs.sigstore.dev/cosign/signing/signing_with_containers/)
- [Sigstore Policy Controller](https://docs.sigstore.dev/policy-controller/overview/)
- [SLSA: Verification](https://slsa.dev/spec/v1.0/verifying-artifacts)
