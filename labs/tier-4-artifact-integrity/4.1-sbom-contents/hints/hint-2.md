The SBOM won't include everything. Look for what's missing:

```
# Check for vendored C library
ls /app/vendor/
strings /app/vendor/libcurl.so | grep -i version

# Check for dynamically loaded modules
grep -r "importlib\|__import__\|dlopen" /app/src/

# Check for build-time dependencies
cat /app/Makefile
```

To create an enriched SBOM, copy the CycloneDX SBOM and manually add
the vendored component:

```
cp /app/sbom-cdx.json /app/sbom-enriched.json
# Edit with jq or vi to add the missing component
```

Document what was missing in `/app/gaps.txt`.
