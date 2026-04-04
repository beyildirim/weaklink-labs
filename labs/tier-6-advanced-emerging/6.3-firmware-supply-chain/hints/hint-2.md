To defend against firmware supply chain attacks:

1. **Create a signature verification script** (`/app/verify_firmware.sh`):
   ```bash
   #!/bin/bash
   FIRMWARE="$1"
   PUBKEY="/app/firmware/vendor_pubkey.pem"
   SIGFILE="${FIRMWARE}.sig"

   # Verify the firmware signature
   openssl dgst -sha256 -verify "$PUBKEY" -signature "$SIGFILE" "$FIRMWARE"
   ```

2. **Generate a signing key pair and sign the legitimate firmware:**
   ```bash
   openssl genpkey -algorithm RSA -out /app/firmware/vendor_privkey.pem -pkeyopt rsa_keygen_bits:4096
   openssl rsa -pubout -in /app/firmware/vendor_privkey.pem -out /app/firmware/vendor_pubkey.pem
   openssl dgst -sha256 -sign /app/firmware/vendor_privkey.pem -out /app/firmware/legitimate_update.bin.sig /app/firmware/legitimate_update.bin
   ```

3. **Generate a firmware SBOM** listing all components in the image:
   ```bash
   # Create a minimal CycloneDX SBOM for the firmware
   cat > /app/firmware/firmware-sbom-cyclonedx.json << EOF
   { "bomFormat": "CycloneDX", "specVersion": "1.5", ... }
   EOF
   ```

4. **Test that tampered firmware is rejected:**
   ```bash
   /app/verify_firmware.sh /app/firmware/tampered_update.bin
   # Should output: Verification Failure
   ```
