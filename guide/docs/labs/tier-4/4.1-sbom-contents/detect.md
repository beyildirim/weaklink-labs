# Lab 4.1: What SBOMs Actually Contain

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

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Identifying SBOM Coverage Gaps in Production

The key signal is **drift between what the SBOM claims and what's actually deployed**. This shows up when vulnerability scanners find CVEs in components absent from the SBOM.

**What to look for:**

- Vulnerability scanner findings for packages not in the SBOM
- SBOMs not regenerated after code changes (stale timestamp vs. build timestamp)
- SBOMs with zero vendored or native components for apps with C/C++ dependencies
- SBOM generation step missing from CI pipeline logs

| Indicator | What It Means |
|-----------|---------------|
| SBOM component count << `dpkg -l | wc -l` in container | SBOM only covers application layer |
| Vulnerability found for package not in SBOM | SBOM tool missed a dependency |
| SBOM timestamp > 7 days older than image build time | SBOM is stale |
| No vendored/native components for a C/C++ project | SBOM tool can't see compiled code |

### CI Integration

Add SBOM generation and cross-validation to your build pipeline:

```yaml
- name: Generate SBOM
  run: syft $IMAGE -o cyclonedx-json > sbom.json

- name: Cross-validate SBOM against vulnerability scan
  run: |
    grype $IMAGE --output json > scan-results.json
    SCAN_PKGS=$(jq -r '.matches[].artifact.name' scan-results.json | sort -u)
    for pkg in $SCAN_PKGS; do
      if ! jq -e ".components[] | select(.name == \"$pkg\")" sbom.json > /dev/null 2>&1; then
        echo "::warning::Vulnerable component '$pkg' found by scanner but missing from SBOM"
      fi
    done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Incomplete SBOMs allow compromised dependencies to go undetected |

**Alert you will see:** "Vulnerability scanner found CVE in component not listed in SBOM"

When your vulnerability scanner reports a finding for a component not in your SBOM, it means:

1. **SBOM tool missed it**: vendored, dynamically loaded, or unrecognized format
2. **SBOM is stale**: dependency added after last generation
3. **SBOM was tampered with**: component deliberately removed (see [Lab 4.7](../4.7-sbom-tampering/index.md))

**Triage steps:**

1. Check SBOM generation time vs. image build time
2. Verify the SBOM was generated in CI (not manually)
3. Run the vulnerability scanner directly against the artifact (not the SBOM)
4. If the component is missing from all tools, file an enrichment ticket

---

## What You Learned

1. **SBOMs capture package manager dependencies**: what's declared in manifests like `requirements.txt`, `package.json`, `go.mod`.
2. **SBOMs miss vendored code, dynamic dependencies, and build tools**: compiled binaries, runtime-loaded modules, and compilers are invisible.
3. **Multiple tools find different things**: no single generator captures everything. Treat the SBOM as one input, not the final word.

## Further Reading

- [SPDX Specification](https://spdx.github.io/spdx-spec/v2.3/)
- [CycloneDX Specification](https://cyclonedx.org/docs/1.5/)
- [NTIA Minimum Elements for SBOM](https://www.ntia.gov/sites/default/files/publications/sbom_minimum_elements_report_0.pdf)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
