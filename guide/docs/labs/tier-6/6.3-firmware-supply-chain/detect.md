# Lab 6.3: Firmware & Hardware Supply Chain

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

## Identifying Firmware Tampering

Firmware attacks are the hardest supply chain compromise to detect because they operate below OS-level monitoring. Detection relies on **hardware attestation (TPM)**, **firmware integrity measurement**, and **anomalous boot behavior**.

**Key indicators:**

- TPM PCR values that differ from expected measurements
- Firmware update events outside maintenance windows
- Secure Boot violations or Secure Boot being disabled
- BMC/IPMI access from unexpected source IPs
- Firmware version mismatches across identical hardware in a fleet

| Indicator | What It Means |
|-----------|---------------|
| TPM PCR measurement mismatch | Different code executed at boot than expected baseline |
| Firmware update from non-approved source | Unauthorized firmware modification |
| Secure Boot violation detected | Unsigned or untrusted code attempted to run at boot |

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Hardware Supply Chain** | [T1195.003](https://attack.mitre.org/techniques/T1195/003/) | Firmware modified during manufacturing or distribution |
| **Pre-OS Boot: System Firmware** | [T1542.001](https://attack.mitre.org/techniques/T1542/001/) | Backdoor persists in UEFI firmware across OS reinstalls |
| **Pre-OS Boot: Component Firmware** | [T1542.002](https://attack.mitre.org/techniques/T1542/002/) | Compromise of NIC, BMC, or SSD controller firmware |

**Alerts:** "TPM PCR measurement mismatch" (hardware attestation), "Firmware update from non-approved source" (asset management), "Secure Boot violation detected" (Windows Event ID 12290/12291).

Firmware compromises are rare but catastrophic. A single compromised image deployed across a fleet means every server has a persistent backdoor that survives OS reinstalls and standard incident response. The MoonBounce implant (2022) demonstrated UEFI rootkits are used in the wild by APT groups.

**Triage steps:**

1. Compare TPM PCR values against baselines
2. Check firmware version against vendor's latest release
3. Compare SHA256 hashes with vendor's official image
4. Check BMC/IPMI access logs
5. If confirmed: remove from service, image the SPI flash for forensics, replace the motherboard

---

### CI Integration

Add this workflow to verify firmware image integrity during the build process. Save as `.github/workflows/firmware-integrity.yml`:

```yaml
name: Firmware Image Integrity

on:
  pull_request:
    paths:
      - "firmware/**"
      - "images/**"
  push:
    branches: [main]
    paths:
      - "firmware/**"

permissions:
  contents: read

jobs:
  verify-firmware:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify firmware image checksums
        run: |
          MANIFEST="firmware/checksums.sha256"
          if [ ! -f "$MANIFEST" ]; then
            echo "::warning::No firmware checksum manifest at $MANIFEST."
            echo "Create one from vendor-provided checksums."
            exit 0
          fi
          echo "Verifying firmware image checksums..."
          FAILED=0
          while IFS= read -r line; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue
            expected_hash=$(echo "$line" | awk '{print $1}')
            filepath=$(echo "$line" | awk '{print $2}')
            if [ -f "$filepath" ]; then
              actual_hash=$(sha256sum "$filepath" | awk '{print $1}')
              if [ "$expected_hash" != "$actual_hash" ]; then
                echo "::error file=$filepath::Firmware hash mismatch: expected $expected_hash, got $actual_hash"
                FAILED=1
              fi
            fi
          done < "$MANIFEST"
          if [ "$FAILED" -eq 0 ]; then
            echo "PASS: All firmware images match expected checksums."
          else
            exit 1
          fi

      - name: Check for unsigned firmware images
        run: |
          UNSIGNED=0
          for img in $(find firmware/ -type f -name '*.bin' -o -name '*.fw' -o -name '*.img' 2>/dev/null); do
            SIG="${img}.sig"
            if [ ! -f "$SIG" ]; then
              echo "::warning file=$img::No signature file found ($SIG). Firmware should be cryptographically signed."
              UNSIGNED=1
            fi
          done
          if [ "$UNSIGNED" -eq 0 ]; then
            echo "PASS: All firmware images have corresponding signature files."
          fi
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **Firmware is the root of the supply chain.** A compromised firmware invalidates all higher-level security controls.
- **CRC32/MD5 checksums are not security.** Without cryptographic signatures verified against a hardware-embedded public key, firmware updates can be modified and pass validation.
- **TPM and Secure Boot are the hardware root of trust.** TPM PCR measurements create an unforgeable record of what firmware was loaded at boot. Secure Boot prevents unsigned code from executing.

## Further Reading

- [NIST SP 800-193: Platform Firmware Resiliency Guidelines](https://csrc.nist.gov/publications/detail/sp/800-193/final)
- [Binarly: UEFI Firmware Vulnerability Research](https://binarly.io/advisories)
- [MITRE ATT&CK: Pre-OS Boot (T1542)](https://attack.mitre.org/techniques/T1542/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)
