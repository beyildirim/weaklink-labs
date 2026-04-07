# Lab 6.6: Case Study. SolarWinds (SUNBURST)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../analyze/" class="phase-step done">Analyze</a>
  <span class="phase-arrow">›</span>
  <a href="../lessons/" class="phase-step done">Lessons</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Identifying SUNBURST and Build Compromises

SUNBURST generated detectable signals: **DNS queries to `avsvmcloud.com`**, **unexpected DLL loading in SolarWinds processes**, and **lateral movement from SolarWinds servers**.

**Key indicators (SUNBURST-specific):**

- DNS queries to `*.avsvmcloud.com`
- `SolarWinds.Orion.Core.BusinessLayer.dll` matching known-bad hashes
- SolarWinds processes making HTTP calls to non-SolarWinds endpoints
- Lateral movement (SMB, WinRM) from SolarWinds servers

**Key indicators (generic build compromise):**

- Build artifacts with different hashes than expected from the same source
- Build pipeline modifications not tracked in version control
- Code signing events outside the build pipeline

| Indicator | What It Means |
|-----------|---------------|
| DNS query to `*.avsvmcloud.com` | SUNBURST C2 communication |
| Known-bad DLL hash in SolarWinds process | SUNBURST implant active |
| Lateral movement from SolarWinds server | Post-compromise escalation |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Backdoor injected via compromised build system |
| **Signed Binary Proxy Execution** | [T1218](https://attack.mitre.org/techniques/T1218/) | Backdoored DLL signed by SolarWinds' certificate |
| **Application Layer Protocol: DNS** | [T1071.004](https://attack.mitre.org/techniques/T1071/004/) | DNS-based C2 communication |

**Alerts:** "DNS query to known SUNBURST C2 domain" (threat intel), "SolarWinds Orion DLL hash matches known-bad" (FIM), "Lateral movement from SolarWinds server" (behavioral).

Every enterprise control designed to verify "is this software from the vendor?" answered "yes" because it was. The question should have been "was the vendor's build process compromised?"

**Triage steps:**

1. Check binary hash against known-bad indicators
2. Check for unusual network activity from updated software
3. Check for lateral movement from the SolarWinds server
4. Assume all accessible credentials are stolen if confirmed
5. Isolate and block C2 indicators

---

### CI Integration

Add this workflow to verify build reproducibility by comparing build outputs against expected digests. Save as `.github/workflows/reproducible-build-check.yml`:

```yaml
name: Build Reproducibility Check

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  verify-build-reproducibility:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and record artifact hashes
        run: |
          echo "--- Build Artifact Integrity ---"
          # Record hashes of all build outputs
          ARTIFACTS_DIR="dist/"
          if [ -d "$ARTIFACTS_DIR" ]; then
            echo "Existing artifacts found. Recording hashes..."
            find "$ARTIFACTS_DIR" -type f -exec sha256sum {} \; | sort > /tmp/pre-build-hashes.txt
            cat /tmp/pre-build-hashes.txt
          fi

      - name: Verify no unexpected files in build output
        run: |
          EXIT_CODE=0
          ARTIFACTS_DIR="dist/"
          if [ -d "$ARTIFACTS_DIR" ]; then
            # Check for suspicious files in build output
            SUSPICIOUS=$(find "$ARTIFACTS_DIR" -type f \( \
              -name '*.dll' -o -name '*.so' -o -name '*.dylib' \
            \) 2>/dev/null || true)
            if [ -n "$SUSPICIOUS" ]; then
              echo "::warning::Binary artifacts found in build output:"
              echo "$SUSPICIOUS"
              echo ""
              echo "Verify these are expected. SolarWinds-style attacks inject"
              echo "malicious DLLs during the build process."
            fi
          fi

      - name: Check for build script modifications
        run: |
          EXIT_CODE=0
          BUILD_CHANGES=$(git diff --name-only origin/main...HEAD -- \
            'Makefile' 'build.sh' 'build/' 'scripts/build*' \
            '.github/workflows/*build*' '.github/workflows/*release*' \
            'setup.py' 'pyproject.toml' || true)
          if [ -n "$BUILD_CHANGES" ]; then
            echo "::warning::Build configuration modified in this PR:"
            echo "$BUILD_CHANGES"
            echo ""
            echo "Build pipeline changes require security review."
            echo "The SolarWinds attack injected code via the build system."
          else
            echo "PASS: No build configuration changes detected."
          fi
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **Build systems are high-value targets.** Compromising the build pipeline lets attackers inject code that source review, signing, and antivirus all miss.
- **Code signing proves authorship, not integrity.** Signing tells you WHO built it, not WHETHER the build was trustworthy.
- **Reproducible builds would have caught SUNBURST.** An independent rebuild producing a different binary would have been detected before distribution.

## Further Reading

- [CISA Emergency Directive 21-01](https://www.cisa.gov/emergency-directive-21-01)
- [CrowdStrike: SUNSPOT. Implant in the Build Environment](https://www.crowdstrike.com/blog/sunspot-malware-technical-analysis/)
- [MITRE ATT&CK: SolarWinds Compromise](https://attack.mitre.org/campaigns/C0024/)
