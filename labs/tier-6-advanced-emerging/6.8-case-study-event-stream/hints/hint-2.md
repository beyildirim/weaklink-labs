To complete the defensive exercises:

1. **Ensure lockfile has integrity hashes:**
   ```bash
   cd /app && npm install --package-lock-only
   # Verify hashes exist
   grep -c '"integrity"' package-lock.json
   ```

2. **Create a maintainer monitoring script** (`/app/monitor_maintainers.sh`):
   ```bash
   #!/bin/bash
   PACKAGE="$1"
   KNOWN_MAINTAINERS="/app/known_maintainers.json"

   # Get current maintainers
   CURRENT=$(npm view "$PACKAGE" maintainers --json 2>/dev/null)

   # Compare against known list
   if ! diff <(echo "$CURRENT" | jq -S .) <(cat "$KNOWN_MAINTAINERS" | jq -S .) > /dev/null 2>&1; then
     echo "WARNING: Maintainer change detected for $PACKAGE"
     echo "Current: $CURRENT"
     echo "Expected: $(cat $KNOWN_MAINTAINERS)"
   fi
   ```

3. **Add npm audit to CI** (`/app/.github/workflows/security.yml`
   or `/app/check_deps.sh`):
   ```bash
   npm audit --audit-level=high
   ```

4. **Write the analysis** (`/app/analysis.md`) covering:
   - event-stream: timeline (Sep 2018), CVE-2018-16492, flatmap-stream
   - ua-parser-js: timeline (Oct 22, 2021), affected versions, 7M downloads
   - npm 2FA enforcement and `--provenance` flag
   - Why transitive dependencies are the real risk
