# Solution: Lab 5.2

## Key actions

1. Render all templates to inspect them before installing:

```bash
helm template my-release /app/metrics-aggregator/ > rendered.yaml
cat rendered.yaml
```

2. Remove the malicious post-install hook:

```bash
rm /app/metrics-aggregator/templates/post-install-hook.yaml
```

3. Create a review marker:

```bash
touch /app/.helm-reviewed
```

4. Create a Kyverno policy to prevent ClusterRoleBinding abuse:

```bash
mkdir -p /app/policies
cat > /app/policies/restrict-clusterrolebinding.yaml << 'EOF'
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-cluster-admin-binding
spec:
  validationFailureAction: Enforce
  rules:
  - name: block-cluster-admin-to-default-sa
    match:
      any:
      - resources:
          kinds:
          - ClusterRoleBinding
    validate:
      message: "ClusterRoleBindings must not grant cluster-admin to default service accounts."
      deny:
        conditions:
          any:
          - key: "{{ request.object.roleRef.name }}"
            operator: Equals
            value: "cluster-admin"
EOF
```

## Why it works

- `helm template` renders all manifests without applying them, letting you review before install
- Removing the hook eliminates the backdoor
- The Kyverno policy blocks future attempts to create overly permissive ClusterRoleBindings
- Always review hooks (`helm.sh/hook` annotations). They run as Jobs and can do anything
