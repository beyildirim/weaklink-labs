# Lab 4.2: SBOM Gaps in Practice

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

## Layered Detection

**Goal:** Complement SBOMs with vulnerability scanning and binary analysis.

### Step 1: Run a vulnerability scanner directly on the image

```bash
grype registry:5000/weaklink-app:vulnerable -o table > /app/vuln-scan.txt
cat /app/vuln-scan.txt
```

Grype scans the actual filesystem, not just package metadata.

### Step 2: Run Trivy in vulnerability mode (not SBOM mode)

```bash
trivy image registry:5000/weaklink-app:vulnerable --severity HIGH,CRITICAL
```

Compare what Trivy finds in vulnerability mode vs. what it included in the SBOM.

### Step 3: Manual binary analysis for vendored components

```bash
docker run --rm registry:5000/weaklink-app:vulnerable \
  strings /app/vendor/libxml2.so | grep -E "^[0-9]+\.[0-9]+\.[0-9]+"

echo "Check: https://nvd.nist.gov/vuln/search?query=libxml2+<VERSION>"
```

### Step 4: Write the gap analysis

```bash
cat > /app/gap-analysis.md << 'ANALYSIS'
# SBOM Gap Analysis

## Missed: vendored libxml2 (CVE-2022-40303, CVE-2022-40304)
- syft: missed - no package manager metadata
- trivy: missed - no dpkg/rpm entry
- cdxgen: missed - not in any manifest file

## Root Cause
The library was compiled from source and placed in /app/vendor/.
No SBOM tool performs binary analysis or version extraction from
compiled shared objects.

## Remediation
- Add vendored components to SBOM manually or via enrichment tooling
- Run binary composition analysis
- Flag any /vendor/ or /third-party/ directories for manual review
ANALYSIS
```

### Step 5: Verify the lab

```bash
weaklink verify 4.2
```
