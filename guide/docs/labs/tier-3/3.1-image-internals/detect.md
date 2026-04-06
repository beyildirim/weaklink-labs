# Lab 3.1: Container Image Internals

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

## Finding Hidden Content in Production Images

Images with more layers than expected, or layer history showing file additions followed by deletions, indicate hidden content. This pattern is abnormal in properly built images.

**Indicators:**

- `docker history` shows `RUN rm` or whiteout entries after `COPY`/`ADD` of executables
- Layer count mismatches between Dockerfile instruction count and actual manifest
- Images significantly larger than expected for their base image
- Registry webhook events showing pushes with unusual layer counts

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Implant Internal Image** | [T1525](https://attack.mitre.org/techniques/T1525/) | Malicious content hidden in a layer survives casual inspection |
| **Masquerading** | [T1036](https://attack.mitre.org/techniques/T1036/) | Image appears identical to the clean version at filesystem level |

---

**Alert:** "Container image layer count exceeds baseline" or "Image history contains add-then-delete pattern"

**Triage steps:**

1. Extract all layers with `docker save` and inspect each individually
2. Compare layer count and digests against expected Dockerfile output
3. Look for executables or scripts that appear only in intermediate layers
4. If unexpected content found, quarantine and rebuild from source

---

## CI Integration

**`.github/workflows/image-layer-audit.yml`:**

```yaml
name: Container Image Layer Audit

on:
  push:
    paths:
      - "Dockerfile*"
      - "docker-compose*.yml"

jobs:
  audit-layers:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install crane
        run: |
          curl -sL https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz \
            | tar xz crane
          sudo mv crane /usr/local/bin/

      - name: Build image
        run: docker build -t audit-target:latest .

      - name: Check for add-then-delete pattern
        run: |
          HISTORY=$(docker history --no-trunc --format '{{.CreatedBy}}' audit-target:latest)
          if echo "$HISTORY" | grep -qE '(rm -rf|rm -f|rm /)' ; then
            echo "::warning::Image history contains file deletion after addition."
            echo "Use multi-stage builds to avoid this pattern."
          fi

      - name: Verify layer count
        run: |
          EXPECTED_LAYERS=$(grep -cE '^(RUN|COPY|ADD) ' Dockerfile || echo 0)
          ACTUAL_LAYERS=$(docker inspect --format '{{len .RootFS.Layers}}' audit-target:latest)
          echo "Dockerfile instructions: $EXPECTED_LAYERS"
          echo "Actual image layers: $ACTUAL_LAYERS"
          if [ "$ACTUAL_LAYERS" -gt $((EXPECTED_LAYERS + 15)) ]; then
            echo "::error::Image has significantly more layers than expected."
            exit 1
          fi

      - name: Scan all layers with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: audit-target:latest
          severity: CRITICAL,HIGH
          exit-code: 1
```

---

## What You Learned

- **Deleted files are not truly deleted.** A whiteout hides the file from the runtime filesystem, but the data remains extractable from the image layers.
- **`docker inspect` shows only the merged view.** You need `docker history --no-trunc` and layer extraction to see everything.
- **Minimal base images reduce risk.** Fewer layers mean less surface area for hidden content.

## Further Reading

- [OCI Image Specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)
- [Dive: exploring container image layers](https://github.com/wagoodman/dive)
- [Google crane tool](https://github.com/google/go-containerregistry/tree/main/cmd/crane)
