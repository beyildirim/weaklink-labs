# Solution: Lab 5.5

## Key actions

1. Fix namespace exemptions. Remove `monitoring` from exempt list:

```yaml
# Only kube-system should be exempt
spec:
  match:
  - excludedNamespaces: ["kube-system"]
```

2. Create a CRD policy to cover the `DatabaseCluster` custom resource:

```bash
cat > /app/policies/restrict-crds.yaml << 'EOF'
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srestrictcrd
spec:
  crd:
    spec:
      names:
        kind: K8sRestrictCRD
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8srestrictcrd
      violation[{"msg": msg}] {
        input.review.object.kind == "CustomResourceDefinition"
        msg := "CRD creation requires security review"
      }
EOF
```

3. Create audit config for drift detection and conftest tests.

4. Write conftest policy tests:

```bash
mkdir -p /app/policies/conftest
cat > /app/policies/conftest/test.rego << 'EOF'
package main

deny[msg] {
  input.kind == "Pod"
  input.spec.containers[_].securityContext.privileged == true
  msg := "Privileged pods are not allowed"
}
EOF
```

## Why it works

- Exempt namespaces are a complete bypass; anything deployed there skips all checks
- CRDs that are not covered by constraints pass through unchecked
- Post-admission mutations are invisible to admission controllers
- Audit mode detects drift between what was admitted and what currently exists
- conftest validates policies offline before deploying them
