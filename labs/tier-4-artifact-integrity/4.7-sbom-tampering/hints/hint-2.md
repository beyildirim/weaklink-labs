To defend against SBOM tampering, sign the SBOM at generation time:

```
cosign sign-blob --key /app/cosign.key \
  --output-signature /app/sbom-original.json.sig \
  /app/sbom-original.json
```

Now verify before consuming:

```
# This should succeed (original, untampered)
cosign verify-blob --key /app/cosign.pub \
  --signature /app/sbom-original.json.sig \
  /app/sbom-original.json

# This should fail (tampered)
cosign verify-blob --key /app/cosign.pub \
  --signature /app/sbom-original.json.sig \
  /app/sbom-tampered.json
```

The tampered SBOM fails verification because its content hash no longer
matches the signature. Any consumer that checks the signature will
reject the tampered SBOM.
