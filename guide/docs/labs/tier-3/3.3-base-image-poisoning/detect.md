# Lab 3.3: Base Image Poisoning

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

## Catching Base Image Compromise

The core signal is a **base image digest change without a corresponding approved update**. Base images should only change through your controlled update process.

**Indicators:**

- Registry push events for base image tags from unexpected users or pipelines
- Base image digest changes not correlated with a planned update ticket
- Build logs showing a different base image digest than the Dockerfile pin
- New layers appearing in a base image that do not match the upstream Dockerfile

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Poisoned base image inherited by all downstream application images |
| **Implant Internal Image** | [T1525](https://attack.mitre.org/techniques/T1525/) | Backdoor embedded in base image, invisible in individual Dockerfiles |

---

**Alerts:**

- "Base image pushed from unauthorized source"
- "Base image digest changed without change request"

A poisoned base image is a force multiplier. If 50 microservices use `python-base:3.12`, poisoning that single image compromises all 50 without touching any application code.

**Triage steps:**

1. Identify blast radius: which Dockerfiles use `FROM` with the affected base?
2. Compare digests against your approved digest list
3. Inspect base image layers for unexpected files, scripts, or binaries
4. Check push history: who, from which IP, through which pipeline?
5. Pin the known-good digest and rebuild every downstream image

**Prevention:** Lock write access to base image repositories. Only your base image CI pipeline should push.

---

## CI Integration

**`.github/workflows/base-image-verify.yml`:**

```yaml
name: Base Image Integrity Check

on:
  push:
    paths:
      - "Dockerfile*"
  schedule:
    - cron: "0 6 * * *"

jobs:
  verify-base:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install crane
        run: |
          curl -sL https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz \
            | tar xz crane
          sudo mv crane /usr/local/bin/

      - name: Verify base image digests
        run: |
          UNPINNED=0
          while IFS= read -r line; do
            if echo "$line" | grep -qE '^FROM ' && ! echo "$line" | grep -q '@sha256:'; then
              IMAGE=$(echo "$line" | awk '{print $2}')
              echo "::error::Base image not pinned by digest: $IMAGE"
              UNPINNED=1
            fi
          done < <(grep -h '^FROM ' Dockerfile*)
          if [ "$UNPINNED" -eq 1 ]; then
            exit 1
          fi
          echo "PASS: All base images are pinned by digest."

      - name: Scan base images
        run: |
          for image in $(grep -ohE '@sha256:[a-f0-9]+' Dockerfile* | sort -u); do
            BASE=$(grep -B1 "$image" Dockerfile* | grep 'FROM' | awk '{print $2}')
            echo "Scanning: $BASE"
            docker pull "$BASE" 2>/dev/null
            trivy image --severity CRITICAL "$BASE"
          done
```

---

## What You Learned

- **`FROM` is a trust statement.** Your image inherits everything from the base, including any backdoors.
- **Base image poisoning is a force multiplier.** One poisoned base compromises every application built on it.
- **Digest pinning is essential.** `FROM python@sha256:abc123...` ensures you build on the exact base you verified.

## Further Reading

- [Docker Official Images: How They Work](https://docs.docker.com/trusted-content/official-images/)
- [XZ Utils Backdoor (CVE-2024-3094)](https://nvd.nist.gov/vuln/detail/CVE-2024-3094)
- [Cosign: Container Image Signing](https://docs.sigstore.dev/cosign/signing/signing_with_containers/)
