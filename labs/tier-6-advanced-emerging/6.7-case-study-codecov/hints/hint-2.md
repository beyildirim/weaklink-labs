To complete the defensive exercises:

1. **Fix the CI configuration** to stop using `curl|bash`:
   ```yaml
   # BEFORE (vulnerable):
   # - run: bash <(curl -s https://codecov.io/bash)

   # AFTER (safe - use pinned GitHub Action):
   - uses: codecov/codecov-action@e28ff129e5465c2c0dcc6f003fc735cb6ae0c673  # v4.5.0
     with:
       token: ${{ secrets.CODECOV_TOKEN }}
   ```

2. **Create a script verification wrapper** (`/app/verify_script.sh`):
   ```bash
   #!/bin/bash
   SCRIPT_URL="$1"
   EXPECTED_SHA256="$2"
   TMPFILE=$(mktemp)
   curl -s "$SCRIPT_URL" -o "$TMPFILE"
   ACTUAL=$(sha256sum "$TMPFILE" | awk '{print $1}')
   if [ "$ACTUAL" != "$EXPECTED_SHA256" ]; then
     echo "HASH MISMATCH: expected $EXPECTED_SHA256, got $ACTUAL"
     rm "$TMPFILE"
     exit 1
   fi
   bash "$TMPFILE"
   rm "$TMPFILE"
   ```

3. **Write the analysis** (`/app/analysis.md`) covering:
   - Timeline: Jan 31 - Apr 1, 2021 (attacker had access for 2 months)
   - How the Docker image creation process was exploited
   - ~29,000 customers potentially affected
   - HashiCorp, Twitch, Confluent among confirmed victims
   - Why `curl|bash` is fundamentally unsafe
