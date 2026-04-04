To defend against tag mutability, update your deployment manifest to
use the full digest reference:

```yaml
# BEFORE (vulnerable):
image: registry:5000/webapp:1.0.0

# AFTER (safe):
image: registry:5000/webapp@sha256:abc123...
```

Get the safe digest first:

```
crane digest registry:5000/webapp:1.0.0
```

Save this to `/app/safe-digest.txt`, then update `/app/deploy/deployment.yml`
to use the `@sha256:` reference.

For Kubernetes admission control, a Kyverno policy like this rejects
tag-only references:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-digest
spec:
  validationFailureAction: Enforce
  rules:
    - name: check-digest
      match:
        any:
          - resources:
              kinds: ["Pod"]
      validate:
        message: "Images must use digest references (@sha256:)"
        pattern:
          spec:
            containers:
              - image: "*@sha256:*"
```
