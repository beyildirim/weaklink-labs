The malicious hook is in `templates/post-install-hook.yaml`. It creates a
`ClusterRoleBinding` granting `cluster-admin` to the `default` service account.

To fix:

```bash
# Remove the malicious hook
rm /app/metrics-aggregator/templates/post-install-hook.yaml

# Create a marker file to confirm you reviewed the templates
touch /app/.helm-reviewed

# Create a Kyverno policy to block this pattern
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
