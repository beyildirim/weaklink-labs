The SolarWinds attack was unique because the malicious code was NEVER
in the source repository. The attackers compromised the build system
itself, injecting code during compilation.

Key attack components:

1. **Build system access.** The attackers gained access to the
   SolarWinds build environment (TeamCity CI/CD).

2. **Source code injection at build time.** A build plugin modified
   `SolarWinds.Orion.Core.BusinessLayer.dll` during compilation,
   adding the SUNBURST backdoor class.

3. **Legitimate code signing.** The backdoored DLL was signed with
   SolarWinds' legitimate code signing certificate, making it trusted.

Examine the simulation:

```bash
# Compare source code vs compiled output
diff /app/source/BusinessLayer.cs /app/build-output/decompiled_BusinessLayer.cs

# The compiled version has extra classes not in the source
grep -n 'OrionImprovementBusinessLayer' /app/build-output/decompiled_BusinessLayer.cs
# This class does NOT exist in the source code
grep -n 'OrionImprovementBusinessLayer' /app/source/BusinessLayer.cs
```

Source code review would NEVER catch this. The backdoor only exists
in the compiled binary.
