Create a SLSA provenance attestation:

```
cat > /app/provenance.json << 'EOF'
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "registry:5000/weaklink-app",
      "digest": {"sha256": "<IMAGE_DIGEST>"}
    }
  ],
  "predicate": {
    "builder": {"id": "https://github.com/weaklink-labs/ci-builder"},
    "buildType": "https://github.com/weaklink-labs/build/v1",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/weaklink-labs/app@refs/heads/main"
      }
    }
  }
}
EOF
```

Get the real digest: `crane digest registry:5000/weaklink-app:attested`

Then attach it: `cosign attest --key /app/cosign.key --predicate /app/provenance.json --type slsaprovenance registry:5000/weaklink-app:attested`
