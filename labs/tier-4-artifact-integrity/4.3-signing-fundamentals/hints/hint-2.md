Sign the image with cosign:

```
cosign sign --key /app/cosign.key registry:5000/weaklink-app:signed
```

Verify it:

```
cosign verify --key /app/cosign.pub registry:5000/weaklink-app:signed
```

Now create a policy that rejects unsigned images. A basic admission
policy at `/app/policy.yaml`:

```yaml
apiVersion: policy/v1
kind: ImageVerificationPolicy
spec:
  images:
    - glob: "registry:5000/**"
  authorities:
    - key:
        data: |
          <paste contents of cosign.pub here>
```
