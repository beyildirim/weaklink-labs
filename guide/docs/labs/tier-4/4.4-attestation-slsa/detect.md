# Lab 4.4: Attestation & Provenance (SLSA)

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

## Catching Unattested Deployments

| Indicator | What It Means |
|-----------|---------------|
| Image has `.sig` but no `.att` tag | Signed but no provenance, possibly built locally |
| Attestation builder ID doesn't match expected CI | Wrong CI system or forged attestation |
| `buildInvocationId` not found in CI system logs | Provenance claims a build that never happened |
| `configSource.uri` points to unexpected repo/branch | Built from unauthorized source |

### CI Integration

Add a `provenance` job after your existing build job:

```yaml
  provenance:
    needs: build
    permissions:
      actions: read
      id-token: write
      packages: write
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v1.9.0
    with:
      image: ghcr.io/${{ github.repository }}
      digest: ${{ needs.build.outputs.digest }}
      registry-username: ${{ github.actor }}
    secrets:
      registry-password: ${{ secrets.GITHUB_TOKEN }}
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Without provenance, locally-built backdoored artifacts are indistinguishable from CI-built ones |
| **Subvert Trust Controls** | [T1553](https://attack.mitre.org/techniques/T1553/) | Bypassing provenance requirements to deploy unattested artifacts |

**Alert:** "Image deployed without SLSA provenance attestation"

Signing proves approval. Provenance proves origin. A signed image could have been built anywhere; a provenance attestation ties the build to a specific CI run, repo, and commit.

**Triage steps:**

1. Check if the image was intentionally deployed without provenance (emergency hotfix?)
2. Look up the image digest in your CI system
3. If no CI build matches, treat as potential supply chain compromise
4. Check who pushed the image to the registry (registry access logs)

---

## What You Learned

1. **Without provenance, CI-built and locally-built are indistinguishable.** An insider can push a backdoored image undetected.
2. **in-toto attestations bind signed provenance claims to artifact digests.** The standard format for SLSA.
3. **Provenance policies should check builder identity**, not just "is there an attestation?"

## Further Reading

- [SLSA Specification](https://slsa.dev/spec/v1.0/)
- [in-toto Attestation Framework](https://github.com/in-toto/attestation)
- [SLSA GitHub Generator](https://github.com/slsa-framework/slsa-github-generator)
