To complete the defensive exercises:

1. **Create a backdoor detection script** (`/app/detect_xz_backdoor.sh`):
   ```bash
   #!/bin/bash
   SRC_DIR="$1"
   # Check for suspicious test files with high entropy
   for f in "$SRC_DIR"/tests/files/*.xz; do
     ENTROPY=$(ent "$f" 2>/dev/null | grep "Entropy" | awk '{print $3}')
     if (( $(echo "$ENTROPY > 7.9" | bc -l) )); then
       echo "SUSPICIOUS: $f has entropy $ENTROPY (possible obfuscated payload)"
     fi
   done
   # Check for obfuscated M4 macros
   if grep -q 'eval.*tr.*head.*tail' "$SRC_DIR"/m4/*.m4 2>/dev/null; then
     echo "BACKDOOR DETECTED: Obfuscated shell commands in M4 macros"
   fi
   ```

2. **Create a build reproducibility script** (`/app/check_reproducible.sh`):
   - Build from source twice in isolated environments
   - Compare the output binaries with `sha256sum` and `diffoscope`

3. **Write the analysis document** (`/app/analysis.md`) covering:
   - Jia Tan's 2-year social engineering timeline (2022-2024)
   - Maintainer burnout exploitation
   - The M4 macro / ifunc hooking mechanism
   - How Andres Freund discovered the backdoor via SSH latency
   - Lessons for the open source ecosystem
