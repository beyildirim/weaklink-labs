# Lab 4.7: SBOM Tampering

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

## SBOMs Are Just JSON Files

### Step 1: Generate an SBOM for the application

```bash
syft /app -o cyclonedx-json > /app/sbom.json
```

### Step 2: Inspect the structure

```bash
cat /app/sbom.json | jq '{
  bomFormat: .bomFormat,
  specVersion: .specVersion,
  serialNumber: .serialNumber,
  components_count: (.components | length)
}'
```

A CycloneDX SBOM is a JSON document with a `components` array. Each component has a name, version, purl, and optional hashes. There is no signature, no MAC, no integrity field.

### Step 3: Find vulnerable components

```bash
grype sbom:/app/sbom.json --output table
```

Note a component with a critical CVE.
