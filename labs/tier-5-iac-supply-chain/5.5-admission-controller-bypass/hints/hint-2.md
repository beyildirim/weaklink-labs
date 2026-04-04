The three bypasses are:

1. **Exempt namespace** -- the `monitoring` namespace is exempted in Gatekeeper
   config. Any pod deployed there skips all policy checks.
2. **Post-admission mutation** -- a CronJob modifies a Deployment's security
   context AFTER admission. Gatekeeper only sees the initial create/update.
3. **Uncovered CRD** -- a custom `DatabaseCluster` CRD is not matched by any
   constraint. It can create pods with elevated privileges.

To fix:

```bash
# 1. Remove unnecessary exemptions from gatekeeper config
# Only kube-system should be exempt

# 2. Create an audit-config.yaml to detect drift
cat > /app/policies/audit-config.yaml << 'EOF'
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
spec:
  sync:
    syncOnly:
    - group: ""
      version: "v1"
      kind: "Pod"
    - group: "apps"
      version: "v1"
      kind: "Deployment"
    - group: "batch"
      version: "v1"
      kind: "CronJob"
EOF

# 3. Create policy for CRDs
# 4. Write conftest tests
mkdir -p /app/policies/conftest
```
