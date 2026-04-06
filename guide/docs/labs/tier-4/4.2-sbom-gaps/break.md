# Lab 4.2: SBOM Gaps in Practice

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The Invisible CVE

**Goal:** A vendored C library with a known CVE exists in the image. No SBOM tool finds it.

### Step 1: Look inside the container

```bash
docker run --rm -it registry:5000/weaklink-app:vulnerable sh

# Inside the container:
ls /app/vendor/
strings /app/vendor/libxml2.so | grep -i "LIBXML"
strings /app/vendor/libxml2.so | grep "2\." | head -5
```

A vendored `libxml2.so` in the vendor directory. The version string reveals known CVEs.

### Step 2: Verify SBOMs missed it

```bash
echo "syft:"; jq '.components[] | select(.name | test("xml"; "i"))' /app/sbom-syft.json
echo "trivy:"; jq '.components[] | select(.name | test("xml"; "i"))' /app/sbom-trivy.json
echo "cdxgen:"; jq '.components[] | select(.name | test("xml"; "i"))' /app/sbom-cdxgen.json
```

All three return nothing. The vendored library is invisible because:

1. Not installed via a package manager (no `dpkg` or `rpm` entry)
2. A compiled `.so` file, not a source package
3. No manifest declaring it as a dependency
4. SBOM tools scan metadata, not binary contents

### Step 3: The false negative

If someone asks "is libxml2 vulnerable?" and you check the SBOM, the answer is "we don't use libxml2." But you do. It's invisible.

### Step 4: Calculate the false negative rate

```bash
docker run --rm registry:5000/weaklink-app:vulnerable sh -c \
  "dpkg-query -f '\${Package}\n' -W | wc -l; pip list --format=freeze 2>/dev/null | wc -l; ls /app/vendor/*.so 2>/dev/null | wc -l"

echo "Best SBOM coverage: $(jq '.components | length' /app/sbom-trivy.json) / TOTAL"
```
