To extract and inspect the injected layer:

```
# Pull the blob for the injected layer digest
crane blob registry:5000/webapp:latest@<injected-layer-digest> > /app/injected.tar.gz

# Extract and inspect
mkdir -p /app/extracted-layers
tar xzf /app/injected.tar.gz -C /app/extracted-layers
find /app/extracted-layers -type f
```

To defend, sign the clean image with cosign:

```
# Generate a keypair (if not already done)
cosign generate-key-pair

# Sign the clean image
cosign sign --key cosign.key registry:5000/webapp:clean 2>&1 | tee /app/cosign-output.txt

# Verify the signature
cosign verify --key cosign.pub registry:5000/webapp:clean
```

Try verifying the tampered image -- it should fail because the injected
layer changed the image digest.

Document your findings including the injected layer digest and the
layer count comparison in `/app/findings.txt`.
