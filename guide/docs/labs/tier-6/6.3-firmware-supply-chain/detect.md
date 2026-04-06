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

## What You Learned

- **Firmware is the root of the supply chain.** A compromised firmware invalidates all higher-level security controls.
- **CRC32/MD5 checksums are not security.** Without cryptographic signatures verified against a hardware-embedded public key, firmware updates can be modified and pass validation.
- **TPM and Secure Boot are the hardware root of trust.** TPM PCR measurements create an unforgeable record of what firmware was loaded at boot. Secure Boot prevents unsigned code from executing.

## Further Reading

- [NIST SP 800-193: Platform Firmware Resiliency Guidelines](https://csrc.nist.gov/publications/detail/sp/800-193/final)
- [Binarly: UEFI Firmware Vulnerability Research](https://binarly.io/advisories)
- [MITRE ATT&CK: Pre-OS Boot (T1542)](https://attack.mitre.org/techniques/T1542/)
