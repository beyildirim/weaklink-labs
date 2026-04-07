The xz-utils backdoor was hidden in plain sight through multiple layers:

1. **The test files.** `tests/files/bad-3-corrupt_lzma2.xz` and
   similar files contained obfuscated binary data that was NOT actually
   test data. It was the backdoor payload.

2. **The build system.** Modified `m4/build-to-host.m4` contained
   obfuscated shell commands that extracted and injected the payload
   during `./configure`.

3. **The activation conditions.** The backdoor ONLY activated when:
   - Building as part of a Debian or RPM package (not from `git clone`)
   - The binary was linked against `libsystemd`
   - Running on x86_64 Linux

Examine the simulated attack components:

```bash
# Look at the obfuscated M4 macro
cat /app/xz-src/m4/build-to-host.m4

# Look at the test file that hides the payload
xxd /app/xz-src/tests/files/bad-3-corrupt_lzma2.xz | head -20

# Trace the extraction pipeline
cat /app/xz-src/extract_payload.sh
```
