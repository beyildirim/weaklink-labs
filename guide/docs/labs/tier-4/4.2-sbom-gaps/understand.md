# Lab 4.2: SBOM Gaps in Practice

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Different Tools, Different Results

**Goal:** Run multiple SBOM generators on the same image and see how their outputs differ.

### Step 1: Pull the target image

```bash
crane pull registry:5000/weaklink-app:vulnerable /tmp/vuln-image.tar
```

### Step 2: Generate SBOMs with three different tools

```bash
# Tool 1: syft
syft registry:5000/weaklink-app:vulnerable -o cyclonedx-json > /app/sbom-syft.json

# Tool 2: trivy
trivy image --format cyclonedx registry:5000/weaklink-app:vulnerable > /app/sbom-trivy.json

# Tool 3: cdxgen
cdxgen -t docker -o /app/sbom-cdxgen.json registry:5000/weaklink-app:vulnerable
```

### Step 3: Compare component counts

```bash
echo "syft:   $(jq '.components | length' /app/sbom-syft.json) components"
echo "trivy:  $(jq '.components | length' /app/sbom-trivy.json) components"
echo "cdxgen: $(jq '.components | length' /app/sbom-cdxgen.json) components"
```

The numbers will differ:

| Tool | Strategy | Strengths | Blind Spots |
|------|----------|-----------|-------------|
| syft | Package manager databases (dpkg, rpm, pip, npm) | Broad language support | Misses vendored/compiled code |
| trivy | Package managers + OS package DBs + advisory matching | Good OS-level coverage | Misses non-standard layouts |
| cdxgen | Language-specific manifest parsing | Deep language support | Weaker on OS packages |

### Step 4: Find the differences

```bash
jq -r '.components[].name' /app/sbom-syft.json | sort -u > /tmp/names-syft.txt
jq -r '.components[].name' /app/sbom-trivy.json | sort -u > /tmp/names-trivy.txt
jq -r '.components[].name' /app/sbom-cdxgen.json | sort -u > /tmp/names-cdxgen.txt

echo "=== Only in syft ==="
comm -23 /tmp/names-syft.txt /tmp/names-trivy.txt

echo "=== Only in trivy ==="
comm -13 /tmp/names-syft.txt /tmp/names-trivy.txt

echo "=== Components all three agree on ==="
comm -12 /tmp/names-syft.txt /tmp/names-trivy.txt | comm -12 - /tmp/names-cdxgen.txt | wc -l
```
