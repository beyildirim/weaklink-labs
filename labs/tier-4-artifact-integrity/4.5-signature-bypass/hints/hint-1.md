Start with bypass #1 -- no enforcement. Deploy the unsigned image:

```
kubectl run test-unsigned --image=registry:5000/weaklink-app:unsigned
kubectl get pods
```

It runs without complaint. Signing only works if verification is enforced.

For bypass #2 -- key confusion, generate an attacker key pair:

```
cosign generate-key-pair --output-key-prefix attacker-cosign
mv attacker-cosign.key attacker-cosign.pub /app/
```

Sign a malicious image with the attacker key:

```
cosign sign --key /app/attacker-cosign.key registry:5000/weaklink-app:attacker-signed
```

If the deployer verifies with `--key /app/attacker-cosign.pub`, it passes.
The image is "signed" -- just not by anyone you trust.
