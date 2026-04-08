# Lab 0.3: How Containers Work

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

## Spotting Container Image Tampering

What to look for:

- Image pushes that overwrite existing tags (especially `latest`, `stable`, `production`)
- Pushes from unusual IPs, service accounts, or outside CI/CD pipelines
- Containers making outbound connections to unexpected destinations
- Unexpected `/debug`, `/admin`, `/shell`, or `/env` endpoints on container ports
- Image pull events where the digest differs from last known digest for that tag

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | Tag overwrites, digest changes, pushes outside deploy windows |
| Implant Internal Image | T1525 | New layers added, unexpected base image changes |
| Deploy Container | T1610 | Containers with no digest pin, unexpected child processes |

---

### SOC Alert Rules

When you see **"Container image digest changed for tag"** or **"Container process spawned unexpected child process"**: someone pushed a new image to your registry using the same tag, replacing the legitimate image. Every subsequent deployment or pod restart pulled the attacker's image. The backdoored container looks identical from the outside but contains additional endpoints, reverse shells, or exfiltration logic. Compare the current image digest against your known-good digest and inspect layers with `docker history` and `docker inspect`.

### CI Integration

Add this GitHub Actions workflow to enforce digest pinning in Dockerfiles. Save as `.github/workflows/dockerfile-lint.yml`:

```yaml
name: Dockerfile Digest Pinning Check

on:
  pull_request:
    paths:
      - '**/Dockerfile*'
      - '**/docker-compose*.yml'
  push:
    branches: [main]
    paths:
      - '**/Dockerfile*'
      - '**/docker-compose*.yml'

permissions:
  contents: read

jobs:
  check-digest-pinning:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check Dockerfiles for tag-only references
        run: |
          EXIT_CODE=0
          echo "Scanning for Dockerfiles..."

          while read -r dockerfile; do
            echo "Checking: ${dockerfile}"

            # Find FROM lines that use tags instead of digests
            UNPINNED=$(grep -n '^FROM ' "$dockerfile" | grep -v '@sha256:' | grep -v 'scratch' || true)

            if [ -n "$UNPINNED" ]; then
              echo "::error file=${dockerfile}::Found unpinned base image(s):"
              echo "$UNPINNED"
              echo ""
              echo "Fix: Replace tag references with digest pins."
              echo "  Before: FROM python:3.11-slim"
              echo "  After:  FROM python:3.11-slim@sha256:abc123..."
              echo ""
              echo "Get the digest with: docker pull python:3.11-slim && docker inspect --format='{{index .RepoDigests 0}}' python:3.11-slim"
              EXIT_CODE=1
            fi
          done < <(find . -name 'Dockerfile*' -type f)

          exit $EXIT_CODE

      - name: Check for :latest tags
        run: |
          LATEST_REFS=$(grep -rn ':latest' --include='Dockerfile*' --include='docker-compose*.yml' . || true)
          if [ -n "$LATEST_REFS" ]; then
            echo "::warning::Found ':latest' tag references (these are mutable and unsafe):"
            echo "$LATEST_REFS"
          fi
```

---

## What You Learned

- **Tags are mutable pointers.** `latest`, `v1.0`, even `stable` can be overwritten at any time without warning.
- **Registries accept overwrites silently.** Pushing a new image with the same tag replaces the old one.
- **Digest pinning is the defense.** Using `@sha256:...` in Dockerfiles and deployments prevents tag substitution attacks because digests are immutable.

## Further Reading

- [Docker Image Digests Explained](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest)
- [Why You Should Pin Docker Image Digests](https://blog.chainguard.dev/pin-your-container-image-digests/)
- [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
