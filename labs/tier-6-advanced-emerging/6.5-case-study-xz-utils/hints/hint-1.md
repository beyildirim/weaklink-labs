The xz-utils backdoor was hidden in plain sight through multiple layers:

1. **The suspicious release indicators.** Start with:
   - `/app/timeline/attack-timeline.md`
   - `/app/indicators/iocs.txt`

2. **The build system.** Your analysis needs to explain:
   - `m4/build-to-host.m4`
   - `./configure`
   - `liblzma`
   - `IFUNC` hooking

3. **The learner deliverables.** The lab verifier expects:
   - `/app/analysis.md`
   - `/app/detect_xz_backdoor.sh`
   - `/app/check_reproducible.sh`

Start by collecting the evidence:

```bash
cat /app/timeline/attack-timeline.md
cat /app/indicators/iocs.txt
```
