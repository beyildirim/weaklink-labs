# Lab 4.7: SBOM Tampering

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

## Spotting Tampered SBOMs

| Indicator | What It Means |
|-----------|---------------|
| Vuln scanner finds CVE in `requests==2.25.0` but SBOM lists `requests==2.31.0` | Version was tampered |
| `sbom-tampered.json` has fewer components than `sbom-original.json` | A component was removed from the SBOM |
| SBOM signature verification fails | Modified after signing |
| `serialNumber` or `metadata.timestamp` doesn't match CI pipeline records | SBOM may have been replaced |

### CI Integration

Generate, sign, and cross-validate in the same pipeline:

```yaml
- name: Generate SBOM from built image
  run: syft $IMAGE -o cyclonedx-json > sbom-original.json

- name: Sign and attach SBOM as attestation
  run: cosign attest --predicate sbom-original.json --type cyclonedx $IMAGE

- name: Cross-validate SBOM against vulnerability scan
  run: |
    grype $IMAGE --output json > scan-results.json
    SCAN_PKGS=$(jq -r '.matches[].artifact.name' scan-results.json | sort -u)
    for pkg in $SCAN_PKGS; do
      if ! jq -e ".components[] | select(.name == \"$pkg\")" sbom-original.json > /dev/null 2>&1; then
        echo "::error::Vulnerable component '$pkg' found by scanner but missing from SBOM"
      fi
    done
```

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Tampering lets a compromised dependency pass compliance checks undetected |
| **Indicator Removal** | [T1070](https://attack.mitre.org/techniques/T1070/) | Removing a component from an SBOM is evidence tampering |

**Alert:** "SBOM signature verification failed" or "Vulnerability found at different version than SBOM declares"

SBOM tampering is the supply chain equivalent of editing audit logs. The attacker doesn't change the artifact; they change the documentation that compliance tools rely on.

**Triage steps:**

1. Verify the SBOM signature
2. Regenerate the SBOM from the actual artifact and compare
3. If version numbers differ, check the actual installed version (`pip show`, `npm list`, `dpkg -l`)
4. If tampering is confirmed, quarantine the artifact and audit who had write access to SBOM storage

---

## What You Learned

1. **SBOMs have no built-in integrity.** A single `jq` command removes a component or changes a version. Tampered SBOMs pass schema validation.
2. **Version tampering is subtler than removal.** Component count stays identical but the CVE match disappears.
3. **Sign SBOMs at generation time and cross-validate against the actual artifact.** Signing detects post-generation tampering; cross-validation catches incomplete generation.

## Further Reading

- [CycloneDX Signing Specification](https://cyclonedx.org/capabilities/signing/)
- [cosign attach sbom](https://docs.sigstore.dev/signing/other_types/#sboms)
- [CISA SBOM Sharing Guidance](https://www.cisa.gov/sbom)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
