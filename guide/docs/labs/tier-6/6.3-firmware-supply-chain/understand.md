# Lab 6.3: Firmware & Hardware Supply Chain

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

## The Trust Chain from Silicon to Software

**Goal:** Understand how firmware updates are distributed, verified, and applied, and where the trust chain can break.

> **Note:** This lab uses simulated firmware files that represent the structure of real UEFI images. In production, you would use binwalk or uefi-firmware-parser for binary analysis.

### Step 1: Explore the firmware update lifecycle

```bash
ls -la /app/firmware/
file /app/firmware/*.bin
```

Firmware images are binary blobs containing boot code, driver initialization, hardware configuration tables (ACPI), and sometimes embedded operating environments.

### Step 2: Analyze a legitimate firmware image

```bash
strings /app/firmware/bios-v1.2.0.bin | head -40
hexdump -C /app/firmware/bios-v1.2.0.bin | head -30
grep -c "DXE" /app/firmware/bios-v1.2.0.bin
```

A UEFI firmware image contains multiple volumes: PEI (Pre-EFI Initialization), DXE (Driver Execution Environment) drivers, boot manager, and NVRAM. Each is a potential injection point.

### Step 3: Understand the update distribution model

```bash
curl -s http://firmware-server:8080/api/updates | python3 -m json.tool
curl -s http://firmware-server:8080/api/updates/bios-v1.3.0/metadata | python3 -m json.tool
```

### Step 4: Check the verification mechanism

```bash
cat /app/firmware/verify_update.sh
ls -la /app/firmware/*.sig /app/firmware/*.asc 2>/dev/null
/app/firmware/verify_update.sh /app/firmware/bios-v1.2.0.bin
```

Some vendors only verify CRC32 or MD5, not a cryptographic signature. Others sign firmware but distribute the public key alongside the image, making the signature useless if the attacker replaces both.
