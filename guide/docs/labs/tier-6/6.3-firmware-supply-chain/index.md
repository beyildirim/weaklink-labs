# Lab 6.3: Firmware & Hardware Supply Chain

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~10 min | Defend: ~10 min | Detect: ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: None</span>
</div>

Firmware runs before the operating system boots, initializes hardware, and establishes the root of trust for everything above it. A compromised firmware update persists across OS reinstalls, survives disk wipes, and operates below the visibility of EDR and antivirus. The 2022 MoonBounce UEFI implant and the LoJax rootkit demonstrate that firmware-level compromise is an active threat vector used by nation-state actors.

### Attack Flow

```mermaid
graph LR
    A[Attacker modifies<br>firmware image] --> B[Backdoor DXE driver<br>injected]
    B --> C[Checksum<br>recalculated]
    C --> D[Firmware passes<br>vendor verification]
    D --> E[Flashed to<br>SPI chip]
    E --> F[Persists across<br>OS reinstalls]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Firmware Images | `/app/firmware/` | Simulated UEFI firmware images (legitimate and modified) |
| Signing Tools | `/app/signing/` | Firmware signing keys and verification utilities |
| Update Server | `firmware-server:8080` | Simulated firmware update distribution server |
| Analysis Tools | `strings`, `hexdump`, `grep` | Firmware analysis and inspection utilities |

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>
