The fix is to always use fully qualified image names that include the
registry hostname:

```yaml
# BEFORE (ambiguous -- Docker decides which registry):
image: myapp:latest

# AFTER (explicit -- no ambiguity):
image: registry:5000/myapp:latest
```

Update `/app/deploy/deployment.yml` to use the fully qualified name.

Then create a registry allowlist policy at `/app/policy/registry-allowlist.yml`:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-registries
spec:
  validationFailureAction: Enforce
  rules:
    - name: allowed-registries
      match:
        any:
          - resources:
              kinds: ["Pod"]
      validate:
        message: "Images must come from approved registries"
        pattern:
          spec:
            containers:
              - image: "registry:5000/*"
```

Document how the confusion attack worked in `/app/findings.txt`.
