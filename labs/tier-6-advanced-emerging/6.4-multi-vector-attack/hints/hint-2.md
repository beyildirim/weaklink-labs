To defend against chained attacks, implement defense-in-depth:

1. **Stage 1 defense (typosquatting):**
   ```bash
   # Fix the typosquatted package name
   sed -i 's/requets/requests/' /app/requirements.txt
   rm -f /tmp/stage1-typosquat

   # Add integrity hashes to lock file
   pip-compile --generate-hashes requirements.txt
   ```

2. **Stage 2 defense (CI poisoning):**
   ```bash
   # Restore the CI config from the protected branch
   cp /app/.github/workflows/ci.yml.original /app/.github/workflows/ci.yml
   rm -f /tmp/stage2-ci-poison

   # Protect CI config with CODEOWNERS
   mkdir -p /app/.github
   echo "/.github/workflows/ @security-team" > /app/.github/CODEOWNERS
   ```

3. **Stage 3 defense (image tampering):**
   ```bash
   rm -f /tmp/stage3-image-backdoor

   # Create image verification script
   cat > /app/verify_image.sh << 'EOF'
   #!/bin/bash
   IMAGE="$1"
   cosign verify --key /app/cosign.pub "$IMAGE"
   EOF
   chmod +x /app/verify_image.sh
   ```

Map each defense to a SLSA level. SLSA 1 = provenance exists.
SLSA 2 = hosted build. SLSA 3 = hardened builds. SLSA 4 = hermetic.
