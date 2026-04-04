The vendored library lives in `/app/vendor/`. None of the SBOM tools
will find it because it's a statically compiled `.so` file, not managed
by a package manager.

Run a vulnerability scan to catch what SBOMs miss:

```
grype weaklink-app:latest -o table > /app/vuln-scan.txt
```

Then manually check the vendored library:

```
strings /app/vendor/libxml2.so | grep -i version
# Compare that version against known CVEs
```

Document your findings:

```
cat > /app/gap-analysis.md << 'EOF'
# SBOM Gap Analysis
## Missed: vendored libxml2 (CVE-XXXX-XXXX)
- syft: missed
- trivy: missed
- Reason: statically compiled, not in any package manager index
EOF
```
