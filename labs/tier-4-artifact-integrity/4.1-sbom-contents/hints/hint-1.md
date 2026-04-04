Generate an SBOM using syft:

```
syft /app -o spdx-json > /app/sbom-spdx.json
syft /app -o cyclonedx-json > /app/sbom-cdx.json
```

Then inspect what fields each format captured:

```
cat /app/sbom-spdx.json | jq '.packages[] | {name, versionInfo, licenseConcluded}'
cat /app/sbom-cdx.json | jq '.components[] | {name, version, licenses}'
```

Compare the two -- do they list the same packages?
