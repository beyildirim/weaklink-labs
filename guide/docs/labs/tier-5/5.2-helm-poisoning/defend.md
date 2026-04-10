# Lab 5.2: Helm Chart Poisoning

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Reviewing Charts and Enforcing Policies

### Step 1: Remove the malicious hook

```bash
rm /app/metrics-aggregator/templates/post-install-hook.yaml
```

### Step 2: Verify the chart is clean

```bash
helm template my-release /app/metrics-aggregator/ | grep 'ClusterRoleBinding'
# Should return nothing
```

### Step 3: Create a review marker

```bash
touch /app/.helm-reviewed
```

### Step 4: Create a Kyverno policy

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

This blocks any ClusterRoleBinding referencing `cluster-admin`, even if a chart slips through code review.


### Additional defenses

1. **Always run `helm template` before `helm install`.** Look for unexpected Jobs, RBAC bindings, and CRDs.
2. **Diff before upgrade.** `helm diff upgrade` (plugin) shows exactly what will change.
3. **Block dangerous hooks in CI.** Scan rendered manifests for `helm.sh/hook` annotations on sensitive resource types.
