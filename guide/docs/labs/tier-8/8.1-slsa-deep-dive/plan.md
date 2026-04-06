# Lab 8.1: SLSA Framework Deep Dive

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../assess/" class="phase-step done">Assess</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Plan</span>
  <span class="phase-arrow">›</span>
  <a href="../document/" class="phase-step upcoming">Document</a>
</div>

**Goal:** Create a concrete action plan with CI/CD changes needed to reach SLSA Level 3.

## Reach Level 1: Generate provenance

```yaml
# .github/workflows/build.yml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@v4
      - name: Build artifact
        id: build
        run: |
          docker build -t myapp:${{ github.sha }} .
          DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' myapp:${{ github.sha }} | cut -d@ -f2)
          echo "digest=${DIGEST}" >> "$GITHUB_OUTPUT"

  provenance:
    needs: build
    permissions:
      actions: read
      id-token: write
      contents: read
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v2.0.0
    with:
      image: ghcr.io/org/myapp
      digest: ${{ needs.build.outputs.digest }}
    secrets:
      registry-username: ${{ github.actor }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}
```

## Reach Level 2: Authenticated provenance

The `slsa-github-generator` signs provenance via Sigstore OIDC automatically. Verify with:

```bash
slsa-verifier verify-image ghcr.io/org/myapp@sha256:abc123... \
  --source-uri github.com/org/repo \
  --builder-id https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml
```

## Reach Level 3: Hardened builds

| Requirement | How to Implement |
|-------------|-----------------|
| Isolated build | GitHub-hosted runners (ephemeral VMs) |
| Non-falsifiable provenance | `slsa-github-generator` in separate, isolated workflow |
| Parameterless build | Remove `workflow_dispatch` inputs |
| Hermetic build (best practice) | Pin all tools/deps to hashes; disable network during build |

## Implementation timeline

| Week | Milestone | SLSA Level |
|:----:|-----------|:----------:|
| 1 | Add `slsa-github-generator` to build workflow | Level 1 |
| 1 | Pin all GitHub Actions to commit SHAs | Level 2 prep |
| 2 | Verify provenance in staging deployment pipeline | Level 2 |
| 3 | Remove `workflow_dispatch` parameters, add `--require-hashes` | Level 3 prep |
| 4 | Deploy admission controller requiring SLSA verification | Level 3 |
