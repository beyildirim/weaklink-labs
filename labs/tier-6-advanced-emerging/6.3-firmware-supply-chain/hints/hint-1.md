The firmware update process loads a binary image and flashes it without
verifying its cryptographic signature. This means any modified image
will be accepted.

Examine the update mechanism:

```bash
# Look at the firmware update script
cat /app/firmware/update.sh

# Check the firmware image headers
xxd /app/firmware/legitimate_update.bin | head -20

# Compare legitimate vs tampered images
sha256sum /app/firmware/legitimate_update.bin
sha256sum /app/firmware/tampered_update.bin

# Look at what the attacker changed
diff <(xxd /app/firmware/legitimate_update.bin) <(xxd /app/firmware/tampered_update.bin) | head -30
```

The tampered image has a backdoor injected into the initialization
routine. Without signature verification, the update script cannot
distinguish between the two images.
