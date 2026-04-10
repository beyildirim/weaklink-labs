Run multiple SBOM generators on the target container image:

```
# Using syft
syft registry:5000/weaklink-app:vulnerable -o cyclonedx-json > /app/sbom-syft.json

# Using trivy
trivy image --format cyclonedx registry:5000/weaklink-app:vulnerable > /app/sbom-trivy.json

# Using cdxgen (if available)
cdxgen -o /app/sbom-cdxgen.json registry:5000/weaklink-app:vulnerable
```

Compare the component counts:

```
echo "syft: $(cat /app/sbom-syft.json | jq '.components | length') components"
echo "trivy: $(cat /app/sbom-trivy.json | jq '.components | length') components"
```

They will likely differ. That is the point.
