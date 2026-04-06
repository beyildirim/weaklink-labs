# Lab 6.3: Firmware & Hardware Supply Chain

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

## Firmware Signing, Secure Boot, and SBOM

### Fix 1: Implement cryptographic firmware signing

```bash
openssl genpkey -algorithm RSA -out /app/signing/fw-signing-key.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -in /app/signing/fw-signing-key.pem -pubout -out /app/signing/fw-signing-pub.pem

openssl dgst -sha256 -sign /app/signing/fw-signing-key.pem \
    -out /app/firmware/bios-v1.2.0.bin.sig \
    /app/firmware/bios-v1.2.0.bin

openssl dgst -sha256 -verify /app/signing/fw-signing-pub.pem \
    -signature /app/firmware/bios-v1.2.0.bin.sig \
    /app/firmware/bios-v1.2.0.bin
echo "Legitimate firmware: signature valid"

openssl dgst -sha256 -verify /app/signing/fw-signing-pub.pem \
    -signature /app/firmware/bios-v1.2.0.bin.sig \
    /tmp/firmware-backdoored.bin 2>&1 || echo "Backdoored firmware: SIGNATURE INVALID"
```

### Fix 2: Create a firmware verification policy

```bash
cat > /app/firmware/verify_secure.sh << 'SHELLEOF'
#!/bin/bash
set -e
FIRMWARE="$1"
SIGNATURE="$1.sig"
PUBKEY="/app/signing/fw-signing-pub.pem"

echo "=== Secure Firmware Verification ==="

if [ ! -f "$SIGNATURE" ]; then
    echo "FAIL: No signature file found"
    exit 1
fi

if ! openssl dgst -sha256 -verify "$PUBKEY" -signature "$SIGNATURE" "$FIRMWARE" 2>/dev/null; then
    echo "FAIL: Signature verification failed"
    exit 1
fi
echo "PASS: Cryptographic signature valid"

HASH=$(sha256sum "$FIRMWARE" | cut -d' ' -f1)
if grep -q "$HASH" /app/firmware/known-good-hashes.txt 2>/dev/null; then
    echo "PASS: Hash matches known-good database"
else
    echo "WARNING: Hash not in known-good database"
fi
echo "=== Firmware verification complete ==="
SHELLEOF
chmod +x /app/firmware/verify_secure.sh
```

### Fix 3: Generate a firmware SBOM

```bash
python3 /app/firmware/generate_fw_sbom.py
```

Generates an SPDX-format SBOM for the firmware image, including SHA256 hash, version, and supplier. With a firmware SBOM, querying "which servers have vulnerable firmware version X?" is a database lookup.

### Fix 4: Verify Secure Boot chain

```bash
cat /app/signing/verify_secureboot.sh
/app/signing/verify_secureboot.sh
```

### Verify the defense

```bash
weaklink verify 6.3
```
