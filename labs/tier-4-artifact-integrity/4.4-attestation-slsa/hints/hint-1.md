Start by examining the two images in the registry:

```
crane manifest registry:5000/weaklink-app:attested
crane manifest registry:5000/weaklink-app:no-provenance
```

Try to verify provenance on the unattested image:

```
cosign verify-attestation --key /app/cosign.pub \
  --type slsaprovenance \
  registry:5000/weaklink-app:no-provenance
```

It fails. You have no way to know where this image was built. It could
have been built on a developer laptop with modified source.
