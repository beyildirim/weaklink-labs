To complete the defensive exercises:

1. **Create a build tampering detection script** (`/app/detect_build_tampering.sh`):
   ```bash
   #!/bin/bash
   BUILD_DIR="$1"
   # Decompile the DLL and compare against source
   # Check for classes/methods not present in source
   diff <(grep 'class ' /app/source/*.cs | sort) \
        <(grep 'class ' "$BUILD_DIR"/decompiled_*.cs | sort)
   if [ $? -ne 0 ]; then
     echo "SUSPICIOUS: Compiled binary contains classes not in source code"
   fi
   ```

2. **Create a reproducible build script** (`/app/verify_build.sh`):
   - Build from source in an isolated environment
   - Compare SHA-256 of output against the distributed binary
   - Flag any differences

3. **Write the analysis** (`/app/analysis.md`) covering:
   - Attack timeline (Oct 2019 - Dec 2020)
   - SUNBURST C2 via DNS (avsvmcloud.com)
   - ~18,000 organizations received the trojanized update
   - US government agencies (Treasury, Commerce, DHS) compromised
   - Build system isolation, SLSA, and hermetic builds as defenses
   - Why source code audits alone are insufficient
