Two different attack patterns, same ecosystem:

**event-stream (2018):**
- Maintainer `dominictarr` was burned out and handed over ownership
  to `right9ctrl` (an attacker using a fake identity)
- The new maintainer added `flatmap-stream` as a dependency
- `flatmap-stream@0.1.1` contained obfuscated code targeting the
  `copay` Bitcoin wallet (stealing wallet keys)
- The malicious code was minified and only activated when imported
  by the specific Copay wallet application

**ua-parser-js (2021):**
- Attacker compromised the maintainer's npm account directly
- Published versions `0.7.29`, `0.8.0`, and `1.0.0` with a
  cryptominer and credential stealer
- Affected 7+ million weekly downloads
- The malicious code ran immediately on install via a preinstall script

Examine the simulated packages:

```bash
# event-stream: Look at the dependency change
diff /app/event-stream/package-v3.3.5.json /app/event-stream/package-v3.3.6.json

# ua-parser-js: Look at the malicious preinstall script
cat /app/ua-parser-js/preinstall_malicious.sh
```
