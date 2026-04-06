# Lab 4.1: What SBOMs Actually Contain

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

## Multiple Tools and Manual Enrichment

**Goal:** Improve SBOM coverage by using multiple generators and manual enrichment.

### Step 1: Run a second generator

```bash
cdxgen -o /app/sbom-cdxgen.json /app/
```

Compare component counts:

```bash
echo "syft found: $(cat /app/sbom-cdx.json | jq '.components | length') components"
echo "cdxgen found: $(cat /app/sbom-cdxgen.json | jq '.components | length') components"
```

Different tools find different things.

### Step 2: Merge results

```bash
# Extract package names from each
cat /app/sbom-cdx.json | jq -r '.components[].name' | sort > /tmp/syft-pkgs.txt
cat /app/sbom-cdxgen.json | jq -r '.components[].name' | sort > /tmp/cdxgen-pkgs.txt

# Find packages unique to each tool
comm -23 /tmp/syft-pkgs.txt /tmp/cdxgen-pkgs.txt > /tmp/only-in-syft.txt
comm -13 /tmp/syft-pkgs.txt /tmp/cdxgen-pkgs.txt > /tmp/only-in-cdxgen.txt

echo "Only in syft:"; cat /tmp/only-in-syft.txt
echo "Only in cdxgen:"; cat /tmp/only-in-cdxgen.txt
```

### Step 3: Manual enrichment for vendored components

Neither tool found the vendored libcurl. Add it manually:

```bash
cp /app/sbom-cdx.json /app/sbom-enriched.json

cat /app/sbom-enriched.json | jq '.components += [{
  "type": "library",
  "name": "libcurl",
  "version": "7.79.0",
  "purl": "pkg:generic/libcurl@7.79.0",
  "description": "Manually added - vendored in /app/vendor/",
  "properties": [{"name": "weaklink:source", "value": "manual-enrichment"}]
}]' > /tmp/enriched.json && mv /tmp/enriched.json /app/sbom-enriched.json
```

### Step 4: Document the gaps

```bash
cat > /app/gaps.txt << 'EOF'
SBOM Coverage Gap Analysis
===========================
Tool: syft + cdxgen

Found: Python packages from requirements.txt and pip metadata
Missed:
  1. vendored libcurl 7.79.0 (/app/vendor/libcurl.so) - added manually
  2. Runtime plugin loaded via importlib - cannot be detected statically
  3. Build-time tools (gcc, cmake) - not runtime dependencies
  4. Helm chart references - infrastructure layer, not application SBOM

Recommendation: Treat SBOM as a snapshot, not a guarantee. Complement
with vulnerability scanning (grype, trivy) on the actual artifact.
EOF
```

### Step 5: Verify the lab

Run the verification from your host terminal:

```bash
weaklink verify 4.1
```
