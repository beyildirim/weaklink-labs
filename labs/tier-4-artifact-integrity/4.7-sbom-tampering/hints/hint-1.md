Start by examining the SBOM and finding the vulnerable component:

```
cat /app/sbom-original.json | jq '.components[] | select(.name == "requests")'
```

Now tamper with it by removing the vulnerable component:

```
cat /app/sbom-original.json | jq 'del(.components[] | select(.name == "requests"))' > /app/sbom-tampered.json
```

Feed the tampered SBOM to a compliance checker:

```
grype sbom:/app/sbom-tampered.json
```

The vulnerability is gone from the SBOM, so the scanner reports all clear,
even though the actual software still has the vulnerable dependency.
