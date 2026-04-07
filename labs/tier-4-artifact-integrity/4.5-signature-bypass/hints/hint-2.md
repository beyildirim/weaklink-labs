For bypass #3, the rollback attack: take a valid signature from an old
image and attach it to a new (malicious) image. Because signatures are
tied to the image digest, this won't work with cosign, but it
demonstrates why digest-based verification matters.

To defend: create an enforcement policy that pins YOUR trusted key:

```yaml
# /app/enforce-policy.yaml
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: require-trusted-signature
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - key:
        data: |
          <paste contents of /app/cosign.pub here>
```

Verify that the attacker-signed image fails when checked against YOUR key:

```
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:attacker-signed
# This should fail -- different key
```

Document all three bypasses in `/app/bypass-report.md`.
