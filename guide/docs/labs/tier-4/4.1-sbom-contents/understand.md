# Lab 4.1: What SBOMs Actually Contain

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

## What Goes Into an SBOM

**Goal:** Generate SBOMs in two formats and understand what fields they capture.

### Step 1: Look at the application

```bash
ls /app/
cat /app/requirements.txt
cat /app/src/main.py
```

A Python web app with dependencies in `requirements.txt`, a `/app/vendor/` directory with a compiled C library (`libcurl.so`), and a dynamically loaded plugin.

### Step 2: Generate an SPDX SBOM

```bash
syft /app -o spdx-json > /app/sbom-spdx.json
```

Inspect it:

```bash
cat /app/sbom-spdx.json | jq '.packages | length'
cat /app/sbom-spdx.json | jq '.packages[] | {name: .name, version: .versionInfo, license: .licenseConcluded}'
```

### Step 3: Generate a CycloneDX SBOM

```bash
syft /app -o cyclonedx-json > /app/sbom-cdx.json
```

Inspect it:

```bash
cat /app/sbom-cdx.json | jq '.components | length'
cat /app/sbom-cdx.json | jq '.components[] | {name, version, type, purl}'
```

### Step 4: Compare the two formats

| Field | SPDX | CycloneDX |
|-------|------|-----------|
| Package identity | `SPDXID` + `name` | `bom-ref` + `purl` |
| Version | `versionInfo` | `version` |
| License | `licenseConcluded` | `licenses[]` |
| Hashes | `checksums[]` | `hashes[]` |
| Relationships | `relationships[]` | `dependencies[]` |

### Step 5: What IS captured

For each package, the SBOM captured:

- **Name and version**: exactly what's installed
- **Package URL (purl)**: a universal identifier (`pkg:pypi/flask@2.3.0`)
- **License**: what the package declares
- **Hashes**: SHA256 of the package archive
- **Supplier**: who published the package (when available)

### Step 6: Notice the gap

At this point the SBOM files are clean inventory snapshots. They still do not tell you what code ran during installation or what behavior would happen at runtime. The next phase focuses on what the SBOM missed entirely.
