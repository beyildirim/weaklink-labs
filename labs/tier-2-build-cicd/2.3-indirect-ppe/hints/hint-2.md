To defend against Indirect PPE:

1. Pin the Makefile and scripts by hash in the CI config
2. Verify file integrity before executing referenced files
3. Add a checksum verification step to CI

Apply the defense:

```bash
# Generate checksums for trusted files
sha256sum Makefile scripts/run-tests.sh > .ci-checksums

# Add verification to CI (already in ci-hardened.yml)
cp /lab/src/repo/.gitea/workflows/ci-hardened.yml \
   /repos/wl-webapp/.gitea/workflows/ci.yml
cp /lab/src/repo/.ci-checksums /repos/wl-webapp/.ci-checksums
```
