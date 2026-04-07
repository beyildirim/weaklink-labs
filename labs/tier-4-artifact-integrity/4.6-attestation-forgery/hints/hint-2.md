Verify the forged attestation. It passes because the signature is valid:

```
cosign verify-attestation --key /app/cosign.pub \
  --type slsaprovenance \
  registry:5000/weaklink-app:malicious
```

This works. The attestation says "built by trusted CI" but you forged it.
The problem: key-based signing lets anyone with the key make any claim.

The defense is keyless signing tied to an OIDC identity:

```yaml
# /app/keyless-policy.yaml
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: require-keyless-provenance
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - keyless:
        url: https://fulcio.sigstore.dev
        identities:
          - issuer: https://token.actions.githubusercontent.com
            subject: https://github.com/weaklink-labs/app/.github/workflows/build.yml@refs/heads/main
```

With keyless signing, the attestation includes the signer's OIDC identity
(verified by Fulcio), which is logged in Rekor. You can't forge
"GitHub Actions built this" unless you actually run GitHub Actions.

Document your findings in `/app/attack-log.md`.
