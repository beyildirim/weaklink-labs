To complete the defensive exercises:

1. **Create a backdoor detection script** (`/app/detect_xz_backdoor.sh`):
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   TARGET="${1:-/app}"
   INDICATORS_FILE="${TARGET}/indicators/iocs.txt"

   if grep -Eqi 'bad-3-corrupt_lzma2\.xz|m4 macro|liblzma|5\.6\.0|5\.6\.1' "$INDICATORS_FILE"; then
     echo "BACKDOOR DETECTED: suspicious xz-utils release indicators present"
     grep -Ei 'bad-3-corrupt_lzma2\.xz|m4 macro|liblzma|5\.6\.0|5\.6\.1' "$INDICATORS_FILE" || true
   else
     echo "No suspicious indicators found"
     exit 1
   fi
   ```

2. **Create a build reproducibility script** (`/app/check_reproducible.sh`):
   - Include `sha256sum` output
   - Include a `diff` or `compare` step in the script body
   - Explain that the real control is rebuilding from reviewed source instead of trusting tarballs

3. **Write the analysis document** (`/app/analysis.md`) covering:
   - Jia Tan's roughly 2-year social engineering timeline
   - Maintainer burnout exploitation
   - The `m4/build-to-host.m4` plus `./configure` mechanism
   - The `IFUNC` / `liblzma` technical path
   - How Andres Freund discovered the backdoor via SSH latency
   - Lessons for the open source ecosystem
